import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminUser extends StatefulWidget {
  const AdminUser({super.key});

  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('http://localhost:5000/api/auth/admin/users'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data['users'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch users')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text('Username: ${u['username'] ?? 'N/A'}'),
                        subtitle: Row(
                          children: [
                            Text('ID: ${u['id'] ?? '-'}'),
                            Text('Email: ${u['email'] ?? 'N/A'}'),
                            Text('Phone: ${u['phone'] ?? 'N/A'}'),
                            Text('Address: ${u['address'] ?? 'N/A'}'),
                            Text('Role: ${u['role'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
