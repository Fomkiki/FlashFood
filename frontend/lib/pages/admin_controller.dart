import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'admin_restaurant_status.dart';
import 'admin_user.dart';

class AdminController extends StatelessWidget {
  const AdminController({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService.clearAuthData();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Admin Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),

              // --- Restaurant Management Button ---
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminRestaurantStatus()),
                  );
                },
                child: const Text(
                  'Restaurant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // --- User Management Button ---
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminUser()),
                  );
                },
                child: const Text(
                  'User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 60),

              // --- Logout Text Button ---
              TextButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}