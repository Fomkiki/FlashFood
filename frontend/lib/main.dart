import 'package:flutter/material.dart';
import 'package:frontend/screens/register_page.dart';

import 'pages/main_page.dart';
import 'screens/login_page.dart';
import 'pages/test_page.dart';
import 'pages/reg_restaurant_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => const MainPage(),
        '/test': (context) => const TestPage(),
        '/reg_restaurant': (context) => const RegRestaurantPage(),
      },
    );
  }
}
