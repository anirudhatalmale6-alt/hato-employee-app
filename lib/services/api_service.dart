import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://tex.app.cw/api/mobile';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('employee_name');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(String pin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'pin': pin}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _headers(),
      );
    } catch (_) {}
    await removeToken();
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: await _headers(),
    );
    if (response.statusCode == 401) throw Exception('Unauthenticated');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getLeaves() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaves'),
      headers: await _headers(),
    );
    if (response.statusCode == 401) throw Exception('Unauthenticated');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['leaves'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createLeave({
    required String day,
    required String startDate,
    String? endDate,
  }) async {
    final body = {
      'day': day,
      'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/leaves'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> deleteLeave(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/leaves/$id'),
      headers: await _headers(),
    );
  }

  static Future<void> updateDeviceToken(String token) async {
    await http.post(
      Uri.parse('$baseUrl/device-token'),
      headers: await _headers(),
      body: jsonEncode({'device_token': token}),
    );
  }
}
