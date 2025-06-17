import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080');

  // Helper method to get token from SharedPreferences
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final userJson = jsonDecode(userString);
        return userJson['token'] as String?;
      }
    } catch (e) {
      print('Error getting token: $e');
    }
    return null;
  }

  // Helper method to build headers with token
  static Future<Map<String, String>> _buildHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    final token = await _getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    final url = '$baseUrl/$endpoint';
    print('Calling API: $url'); // Debug log

    try {
      final headers = await _buildHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load data: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  static Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      print('data: $data');
      final headers = await _buildHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  static Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final headers = await _buildHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to update: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  static Future<void> delete(String endpoint) async {
    try {
      final headers = await _buildHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
