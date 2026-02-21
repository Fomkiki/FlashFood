import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> restaurants = [];
  List<dynamic> filteredRestaurants = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
    searchController.addListener(_filterRestaurants);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchRestaurants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse("http://localhost:5000/api/restaurant"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          restaurants = data["restaurants"] ?? [];
          filteredRestaurants = restaurants;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterRestaurants() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredRestaurants = restaurants;
      } else {
        filteredRestaurants = restaurants
            .where((res) =>
                res['name_res'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search restaurants...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                // Restaurant List
                Expanded(
                  child: filteredRestaurants.isEmpty
                      ? const Center(child: Text('No restaurants found'))
                      : ListView.builder(
                          itemCount: filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = filteredRestaurants[index];
                            return RestaurantCard(restaurant: restaurant);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final dynamic restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuPage(restaurant: restaurant),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Square Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: restaurant['img_url'] != null
                      ? Image.network(
                          restaurant['img_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.restaurant,
                              size: 50,
                              color: Colors.grey[600],
                            );
                          },
                        )
                      : Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Restaurant Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Name
                    Text(
                      restaurant['name_res'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Zone
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          restaurant['zone'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Open/Close Time
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant['open_time'] ?? 'N/A'} - ${restaurant['close_time'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              const Icon(
                Icons.arrow_forward,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
