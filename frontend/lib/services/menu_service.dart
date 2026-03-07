import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MenuService {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  Future<bool> addMenu(
    int idRes,
    Map<String, String> fields,
    Uint8List? imageBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var uri = Uri.parse("$baseUrl/restaurant/$idRes/add");
    var request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes("image", imageBytes, filename: "menu.jpg"),
      );
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return true;
    } else {
      print(responseData);
      return false;
    }
  }

  Future<List<dynamic>> allMenu(int idRes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse("$baseUrl/restaurant/$idRes/menu"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['menu'];
    } else {
      throw Exception('Failed to load menus');
    }
  }

  Future<Map<String, dynamic>> getMenusById(int idRes, int idMenu) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse("$baseUrl/restaurant/$idRes/menu/$idMenu"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['menu'];
    } else {
      throw Exception('Failed to load menus');
    }
  }

  Future<bool> updateMenu(
    int idRes,
    int idMenu,
    Map<String, dynamic> fields,
    Uint8List? imageBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var uri = Uri.parse("$baseUrl/restaurant/$idRes/edit/$idMenu");
    var request = http.MultipartRequest("PUT", uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(
      fields.map((key, value) => MapEntry(key, value.toString())),
    );

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes("image", imageBytes, filename: "menu.jpg"),
      );
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return true;
    } else {
      print(responseData);
      return false;
    }
  }
}
