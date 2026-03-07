import 'package:flutter/material.dart';
import 'package:frontend/pages/edit_menu_page.dart';
import 'package:frontend/services/menu_service.dart';

class MenuResPage extends StatefulWidget {
  final int id_res;
  const MenuResPage({super.key, required this.id_res});

  @override
  State<MenuResPage> createState() => _MenuResPageState();
}

class _MenuResPageState extends State<MenuResPage> {
  late Future<List<dynamic>> menus;
  @override
  void initState() {
    super.initState();
    menus = MenuService().allMenu(widget.id_res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu of Restaurant'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: menus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final menus = snapshot.data!;
          return ListView.separated(
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final res = menus[index];
              const String baseImageUrl = "http://10.0.2.2:5000/";
              final String imagePath = res['img_url'].replaceAll("\\", "/");
              final String fullImageUrl = baseImageUrl + imagePath;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMenuPage(
                          idRes: res['id_res'],
                          idMenu: res['id'],
                          menu: res,
                          fullImageUrl: fullImageUrl,
                        ),
                      ),
                    );
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
                                res['name_menu'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                res['category'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                "${res['price']} baht",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
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
