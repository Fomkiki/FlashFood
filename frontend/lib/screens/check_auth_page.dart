import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckAuthPage extends StatefulWidget {
  const CheckAuthPage({super.key});

  @override
  State<CheckAuthPage> createState() => _CheckAuthPageState();
}

class _CheckAuthPageState extends State<CheckAuthPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      try {
        final res = await http.get(
          Uri.parse("http://10.0.2.2:5000/api/auth/me"),
          headers: {"Authorization": "Bearer $token"},
        );

        if (res.statusCode == 200) {
          // Parse user data to get role
          final userData = jsonDecode(res.body);
          final userRole = userData["user"][0]["role"];
          
          // Save user role to SharedPreferences
          await prefs.setString("userRole", userRole);
          
          // Redirect based on role
          if (userRole == 'admin') {
            Navigator.pushReplacementNamed(context, "/admin");
          } else {
            Navigator.pushReplacementNamed(context, "/main");
          }
        } else {
          await prefs.remove("token");
          await prefs.remove("userRole");
          Navigator.pushReplacementNamed(context, "/login");
        }
      } catch (e) {
        await prefs.remove("token");
        await prefs.remove("userRole");
        Navigator.pushReplacementNamed(context, "/login");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
