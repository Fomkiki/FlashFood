import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:5000/api/auth";

  Future<bool> register(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print(response.body);
      return false;
    }
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw Exception(body["message"] ?? "Login failed");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}

Future<Map<String, dynamic>> getUserData(String token) async {
  final url = Uri.parse("http://localhost:5000/api/auth/me");

  final response = await http.get(
    url,
    headers: {"Authorization": "Bearer $token"},
  );

  return json.decode(response.body);
}
