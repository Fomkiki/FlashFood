import 'dart:convert';

import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl = 'http://localhost:5000/api/cart';

  Future<void> addToCart({required int menuId, required int amount}) async {
    final headers = await ApiService.getAuthHeader();

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
