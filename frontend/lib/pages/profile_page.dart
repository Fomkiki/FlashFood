import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  late TextEditingController usernameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    fetchUser();
  }

  @override
  void dispose() {
    usernameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse("http://localhost:5000/api/auth/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      user = data["user"][0];
      isLoading = false;
    });
  }

  Future<void> updateProfile(
    String newUsername,
    String newAddress,
    String newPhone,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.put(
        Uri.parse("http://localhost:5000/api/auth/update"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": newUsername,
          "address": newAddress,
          "phone": newPhone,
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          user?['username'] = newUsername;
          user?['address'] = newAddress;
          user?['phone'] = newPhone;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void showEditDialog() {
    usernameController.text = user?['username'] ?? '';
    addressController.text = user?['address'] ?? '';
    phoneController.text = user?['phone'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (usernameController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
              } else {
                updateProfile(
                  usernameController.text,
                  addressController.text,
                  phoneController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'),backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Profile Picture (Default Image)
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              // Username
              Text(
                user?['username'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Phone
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    user?['phone'] ?? 'N/A',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Location/Address
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      user?['address'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              // Role
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: user?['role'] == 'restaurant'
                      ? Colors.orange[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Role: ${user?['role'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: user?['role'] == 'restaurant'
                        ? Colors.orange[800]
                        : Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (user?['role'] == 'restaurant') ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/owner_res');
                  },
                  child: const Text('My Restaurants'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: showEditDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Logout Button
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
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
