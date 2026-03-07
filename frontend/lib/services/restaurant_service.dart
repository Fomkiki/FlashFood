import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantService {
  final String baseUrl = 'http://10.0.2.2:5000/api/restaurant';

  Future<bool> registerRestaurant(
    Map<String, String> fields,
    Uint8List? imageBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var uri = Uri.parse("$baseUrl/register");
    var request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          imageBytes,
          filename: "restaurant.jpg",
        ),
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

  Future<List<dynamic>> ownerRes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['restaurants'];
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<bool> updateRestaurant(
    int idRes,
    Map<String, String> fields,
    Uint8List? imageBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var uri = Uri.parse("$baseUrl/$idRes");
    print("URL: $uri");
    var request = http.MultipartRequest("PUT", uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: "restaurant.jpg",
        ),
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

  Future<Map<String, dynamic>> getRestaurants(int idRes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse("$baseUrl/$idRes"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['restaurant'];
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
}
