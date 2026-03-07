import 'package:flutter/material.dart';
import 'package:frontend/pages/main_res_page.dart';
import '../services/restaurant_service.dart';

class OwnerResPage extends StatefulWidget {
  const OwnerResPage({super.key});

  @override
  State<OwnerResPage> createState() => _OwnerResPageState();
}

class _OwnerResPageState extends State<OwnerResPage> {
  late Future<List<dynamic>> Restaurants;

  void loadRestaurants() {
    setState(() {
      Restaurants = RestaurantService().ownerRes();
    });
  }

  @override
  void initState() {
    super.initState();
    loadRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Restaurants"),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Restaurants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final restaurants = snapshot.data!;

          return ListView.separated(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final res = restaurants[index];
              const String baseImageUrl = "http://10.0.2.2:5000/";
              final String imagePath = res['img_url'].replaceAll("\\", "/");
              final String fullImageUrl = baseImageUrl + imagePath;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MainResPage(restaurant: res, ImgUrl: fullImageUrl),
                      ),
                    );

                    loadRestaurants();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            fullImageUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                res['name_res'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: res['status_res'] == 'open'
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      res['status_res'].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, int index) => const Divider(),
          );
        },
      ),
    );
  }
}
