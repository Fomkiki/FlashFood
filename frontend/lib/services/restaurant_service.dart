import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantService {
  final String baseUrl = 'http://localhost:5000/api/restaurant';

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
          "image", // ต้องตรงกับ backend
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
}
