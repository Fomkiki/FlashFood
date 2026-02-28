import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminRestaurantStatus extends StatefulWidget {
  const AdminRestaurantStatus({super.key});

  @override
  State<AdminRestaurantStatus> createState() => _AdminRestaurantStatusState();
}

class _AdminRestaurantStatusState extends State<AdminRestaurantStatus> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllRestaurants();
  }

  Future<void> fetchAllRestaurants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse("http://localhost:5000/api/restaurant/admin/all"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          restaurants = List<Map<String, dynamic>>.from(data["restaurants"] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateRestaurantStatus(int id, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.put(
        Uri.parse("http://localhost:5000/api/restaurant/admin/$id/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "status": newStatus,
        }),
      );

      if (res.statusCode == 200) {
        // Update local state
        final index = restaurants.indexWhere((r) => r['id'] == id);
        if (index != -1) {
          setState(() {
            restaurants[index]['status_reg'] = newStatus;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showStatusDialog(int restaurantId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Restaurant Status'),
        content: const Text('Select new status:'),
        actions: [
          TextButton(
            onPressed: () {
              updateRestaurantStatus(restaurantId, 'waiting_approve');
              Navigator.pop(context);
            },
            child: const Text('Pending'),
          ),
          TextButton(
            onPressed: () {
              updateRestaurantStatus(restaurantId, 'success');
              Navigator.pop(context);
            },
            child: const Text('Approved'),
          ),
          TextButton(
            onPressed: () {
              updateRestaurantStatus(restaurantId, 'not_approve');
              Navigator.pop(context);
            },
            child: const Text('Rejected'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'waiting_approve':
        return Colors.orange;
      case 'not_approve':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Management'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurants.isEmpty
              ? const Center(
                  child: Text('No restaurants found'),
                )
              : ListView.builder(
                  itemCount: restaurants.where((r) => r['status_reg'] != 'not_approve').length,
                  itemBuilder: (context, index) {
                    final filteredRestaurants = restaurants.where((r) => r['status_reg'] != 'not_approve').toList();
                    final restaurant = filteredRestaurants[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Image.network(
                                      "http://localhost:5000/${restaurant['img_url']}",
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(child: Text('Image -')),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurant['name_res'] ?? 'N/A',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Text('Owner ID: ${restaurant['id_users'] ?? 'N/A'}'),
                                      Text('Phone: ${restaurant['phone'] ?? 'N/A'}'),
                                      Text('Address: ${restaurant['address'] ?? 'N/A'}'),
                                      Text('Hours: ${restaurant['open_time'] ?? 'N/A'} - ${restaurant['close_time'] ?? 'N/A'}'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    showStatusDialog(restaurant['id'], restaurant['status_reg']);
                                  },
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(restaurant['status_reg']).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Status: ${restaurant['status_reg']?.toUpperCase() ?? 'N/A'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: getStatusColor(restaurant['status_reg']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
