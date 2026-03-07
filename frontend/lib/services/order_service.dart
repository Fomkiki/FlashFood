import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  final baseUrl = "http://10.0.2.2:5000/api/orders";
  Future<List<Map<String, dynamic>>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['orders']);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<bool> paymentOrder(int idOrder) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.put(
      Uri.parse("$baseUrl/$idOrder/payment"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<dynamic>> getOrdersRes(int id_res) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse("$baseUrl/res/$id_res"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['orders'];
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<List<dynamic>> getDetailOrder(int idOrder) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse("$baseUrl/detail/$idOrder"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['order'];
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<bool> updateOrderStatus(int idOrder, String status) async {
    print(idOrder);
    print(status);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.put(
      Uri.parse("$baseUrl/$idOrder/$status"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
