import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
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
      final res = await http.get(
        Uri.parse('http://localhost:5000/api/auth/admin/users'),
        headers: await ApiService.getAuthHeader(),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data['users'] ?? []);
          users.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    await ApiService.clearAuthData();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),backgroundColor: Colors.orange
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
                        title: Text('ID: ${u['id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Username: ${u['username'] ?? 'N/A'}'),
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
