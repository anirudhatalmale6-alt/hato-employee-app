import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _pin = [];
  bool _loading = false;
  String? _error;

  void _onKeyPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(digit);
        _error = null;
      });
      if (_pin.length == 4) {
        _login();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _error = null;
      });
    }
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.login(_pin.join());
      if (result.containsKey('token')) {
        await ApiService.setToken(result['token']);
        final emp = result['employee'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('employee_name', '${emp['first_name']} ${emp['last_name']}');
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
      } else {
        setState(() {
          _error = result['message'] ?? 'Login failed';
          _pin.clear();
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error. Please try again.';
        _pin.clear();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? const Color(0xFFD32F2F) : Colors.transparent,
            border: Border.all(color: const Color(0xFFD32F2F), width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 80, height: 64);
            }
            if (key == 'back') {
              return SizedBox(
                width: 80,
                height: 64,
                child: IconButton(
                  onPressed: _onBackspace,
                  icon: const Icon(Icons.backspace_outlined, size: 28, color: Color(0xFF424242)),
                ),
              );
            }
            return SizedBox(
              width: 80,
              height: 64,
              child: TextButton(
                onPressed: () => _onKeyPress(key),
                child: Text(
                  key,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Color(0xFF424242)),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.flight_takeoff, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hato Employee',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your 4-digit PIN',
                  style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 40),
                _buildPinDots(),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 24),
                _buildKeypad(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
