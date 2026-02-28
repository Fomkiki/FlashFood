import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MenuService {
  final String baseUrl = 'http://localhost:5000/api';

  Future<bool> addMenu(
    int id_res,
    Map<String, String> fields,
    Uint8List? imageBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var uri = Uri.parse("$baseUrl/restaurant/$id_res/add");
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

  Future<List<dynamic>> allMenu(int id_res) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse("$baseUrl/restaurant/$id_res/menu"),
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
}
