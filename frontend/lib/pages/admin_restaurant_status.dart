import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
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
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/restaurant/admin/all"),
        headers: await ApiService.getAuthHeader(),
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
      final res = await http.put(
        Uri.parse("http://10.0.2.2:5000/api/restaurant/admin/$id/status"),
        headers: await ApiService.getAuthHeader(),
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
        title: const Text('Restaurant Management'),backgroundColor: Colors.orange
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
                                      "http://10.0.2.2:5000/${restaurant['img_url']}",
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
                                    updateRestaurantStatus(restaurant['id'], 'success');
                                  },
                                  child: const Text('Approve'),
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
