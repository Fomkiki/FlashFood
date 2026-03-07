import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void login() async {
    setState(() => isLoading = true);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text(
                'Login',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                obscureText: obscurePassword,
                controller: passwordCtrl,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text("Not account ?"),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    "email": emailCtrl.text,
                    "password": passwordCtrl.text,
                  };

                  final res = await authService.login(data);

                  if (res.containsKey("token")) {
                    final String token = res["token"];

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString("token", token);

                    try {
                      final userRes = await http.get(
                        Uri.parse("http://10.0.2.2:5000/api/auth/me"),
                        headers: {"Authorization": "Bearer $token"},
                      );

                      if (userRes.statusCode == 200) {
                        final userData = jsonDecode(userRes.body);
                        final userRole = userData["user"][0]["role"];

                        if (userRole == 'admin') {
                          Navigator.pushReplacementNamed(context, "/admin");
                        } else {
                          Navigator.pushReplacementNamed(context, "/main");
                        }
                      } else {
                        Navigator.pushReplacementNamed(context, "/main");
                      }
                    } catch (e) {
                      Navigator.pushReplacementNamed(context, "/main");
                    }
                  } else {
                    const snackBar = SnackBar(content: Text("Login failed"));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: isLoading ? CircularProgressIndicator() : Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
