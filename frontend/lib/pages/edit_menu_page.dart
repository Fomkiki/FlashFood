import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/main_res_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/menu_service.dart';

class EditMenuPage extends StatefulWidget {
  final int idMenu;
  final int idRes;
  final Map<String, dynamic> menu;
  final String fullImageUrl;
  const EditMenuPage({
    super.key,
    required this.idMenu,
    required this.idRes,
    required this.menu,
    required this.fullImageUrl,
  });

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  late Map<String, dynamic> newMenu;
  late String newImgUrl;

  @override
  void initState() {
    super.initState();

    newMenu = Map.from(widget.menu);
    newImgUrl = widget.fullImageUrl;
  }

  Future<void> reloadData() async {
    final service = MenuService();
    final newData = await service.getMenusById(widget.idRes, widget.idMenu);

    setState(() {
      newMenu = Map.from(newData);
      const String baseImageUrl = "http://10.0.2.2:5000/";
      final String imagePath = newMenu['img_url'].replaceAll("\\", "/");
      newImgUrl = baseImageUrl + imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu '),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "$newImgUrl?${DateTime.now().millisecondsSinceEpoch}",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  newMenu['name_menu'],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Note : ${newMenu['note']}",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                "Price: ${newMenu['price']}",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                "Category: ${newMenu['category']}",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                "status: ${newMenu['status_menu']}",
                style: TextStyle(
                  fontSize: 20,
                  color: newMenu['status_menu'] == 'on_sale'
                      ? Colors.green
                      : Colors.red,
                ),
              ),

              SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 140, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: EditCard(menu: newMenu, ImgUrl: newImgUrl),
                        );
                      },
                    );
                    print(result);
                    if (result == true) {
                      await reloadData();
                    }
                  },
                  child: const Text(
                    'Edit Menu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditCard extends StatefulWidget {
  final Map<String, dynamic> menu;
  final String ImgUrl;
  const EditCard({super.key, required this.menu, required this.ImgUrl});

  @override
  State<EditCard> createState() => _EditCardState();
}

class _EditCardState extends State<EditCard> {
  late TextEditingController name_menuController;
  late TextEditingController noteController;
  late TextEditingController priceController;
  String? categoryMenu;
  String? selectedStatus;
  final List<String> categories = ['main_course', 'drink', 'dessert'];
  final List<String> status = ['on_sale', 'soldout'];
  Uint8List? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    name_menuController = TextEditingController(text: widget.menu['name_menu']);
    noteController = TextEditingController(text: widget.menu['note']);
    priceController = TextEditingController(text: widget.menu['price']);
    categoryMenu = widget.menu['category'];
    selectedStatus = widget.menu['status_menu'];
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImage = bytes;
      });
    }
  }

  Future<void> submitForm() async {
    final fields = {
      "name_menu": name_menuController.text,
      "note": noteController.text,
      "price": double.parse(priceController.text),
      "category": categoryMenu,
      "status_menu": selectedStatus,
    };
    print(fields);
    final service = MenuService();

    final success = await service.updateMenu(
      widget.menu['id_res'],
      widget.menu['id'],
      fields,
      selectedImage,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu updated successfully')),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update menu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            selectedImage != null
                ? Image.memory(selectedImage!, height: 150, width: 150)
                : Image.network(widget.ImgUrl, height: 150, width: 150),
            SizedBox(height: 12),
            TextButton(
              onPressed: pickImage,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(223, 173, 173, 173),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Update Image',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: name_menuController,
              decoration: const InputDecoration(labelText: 'Name of Menu'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: categoryMenu,
              decoration: InputDecoration(
                labelText: "Category of Menu",
                border: const OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (categories) => DropdownMenuItem(
                      value: categories,
                      child: Text(categories),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => categoryMenu = value),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: InputDecoration(
                labelText: "Status of Menu",
                border: const OutlineInputBorder(),
              ),
              items: status
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedStatus = value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 140, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: submitForm,
              child: const Text(
                'Update Menu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
