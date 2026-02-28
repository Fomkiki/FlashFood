import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/menu_service.dart';
import 'package:image_picker/image_picker.dart';

class AddMenuPage extends StatefulWidget {
  final int id_res;
  const AddMenuPage({super.key, required this.id_res});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final nameMenuController = TextEditingController();
  final priceController = TextEditingController();
  final noteController = TextEditingController();
  String? categoryMenu;
  Uint8List? selectedImage;
  bool isLoading = false;

  final List<String> categories = ['main_course', 'drink', 'dessert'];
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImage = bytes;
      });
    }
  }

  Future<void> submitForm() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image.')));
      return;
    }
    setState(() => isLoading = true);

    final fields = {
      "name_menu": nameMenuController.text,
      "price": priceController.text,
      "note": noteController.text,
      "category": categoryMenu ?? "",
    };

    final service = MenuService();

    final success = await service.addMenu(widget.id_res, fields, selectedImage);
    if (success) {
      nameMenuController.clear();
      priceController.clear();
      noteController.clear();

      setState(() {
        selectedImage = null;
        categoryMenu = null;
      });
    }

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menu added successfully')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add menu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Menu')),
      body: Center(
        child: Container(
          width: 300,
          height: 500,
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
            children: [
              SizedBox(height: 12),
              Expanded(
                child: selectedImage != null
                    ? Image.memory(selectedImage!)
                    : const Text('No image selected'),
              ),
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
                controller: nameMenuController,
                decoration: const InputDecoration(labelText: 'Name Menu'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: categoryMenu,
                decoration: const InputDecoration(labelText: 'Category Menu'),
                items: categories
                    .map(
                      (categories) => DropdownMenuItem(
                        value: categories,
                        child: Text(categories),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => categoryMenu = value),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isLoading ? null : submitForm,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Add Menu',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
