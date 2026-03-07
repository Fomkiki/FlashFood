import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class CartService {
  final baseUrl = "http://10.0.2.2:5000/api/cart";

  Future<List<dynamic>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse("$baseUrl/items"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['result'];
    } else {
      throw ('Cart Empty');
    }
  }

  Future<bool> updateCart(int idMenu, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.put(
      Uri.parse("$baseUrl/items/$idMenu"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"amount": amount}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeCart(int idMenu) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.delete(
      Uri.parse("$baseUrl/items/$idMenu"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.post(
      Uri.parse("$baseUrl/checkout"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addToCart({required int menuId, required int amount}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    final response = await http.post(
      Uri.parse('$baseUrl/add/$menuId'),
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 201) {
      return;
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to add to cart');
    } catch (_) {
      throw Exception('Failed to add to cart');
    }
  }
}
