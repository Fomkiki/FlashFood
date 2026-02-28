import 'package:flutter/material.dart';
import 'package:frontend/pages/add_menu_page.dart';
import 'package:frontend/pages/edit_res_page.dart';
import 'package:frontend/pages/menu_res_page.dart';

class MainResPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String ImgUrl;
  const MainResPage({
    super.key,
    required this.restaurant,
    required this.ImgUrl,
  });

  @override
  State<MainResPage> createState() => _MainResPageState();
}

class _MainResPageState extends State<MainResPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      EditResPage(restaurant: widget.restaurant, ImgUrl: widget.ImgUrl),
      const Placeholder(),
      AddMenuPage(id_res: widget.restaurant['id']),
      MenuResPage(id_res: widget.restaurant['id']),
    ];
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Edit_Restaurant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dining),
            label: 'Orders_Restaurant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Add Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mode_edit_outline),
            label: 'All Menu',
          ),
        ],
      ),
    );
  }
}
