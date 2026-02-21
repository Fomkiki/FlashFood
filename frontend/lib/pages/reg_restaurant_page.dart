import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/restaurant_service.dart';

class RegRestaurantPage extends StatefulWidget {
  const RegRestaurantPage({super.key});

  @override
  State<RegRestaurantPage> createState() => _RegRestaurantPageState();
}

class _RegRestaurantPageState extends State<RegRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final openController = TextEditingController();
  final closeController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String? selectedZone;
  Uint8List? selectedImageBytes;
  bool isLoading = false;

  final List<String> zones = ['Zone 1', 'Zone 2', 'Zone 3'];
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image.')));
      return;
    }

    setState(() => isLoading = true);

    final fields = {
      "name_res": nameController.text,
      "open_time": openController.text,
      "close_time": closeController.text,
      "zone": selectedZone ?? "",
      "phone": phoneController.text,
      "address": addressController.text,
    };

    final service = RestaurantService();

    // ส่ง bytes แทน File
    final success = await service.registerRestaurant(
      fields,
      selectedImageBytes!,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful')));
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Restaurant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name of Restaurant',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: openController,
                decoration: const InputDecoration(
                  labelText: 'Opening Time',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: closeController,
                decoration: const InputDecoration(
                  labelText: 'Closing Time',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedZone,
                decoration: const InputDecoration(
                  labelText: 'Zone',
                  border: OutlineInputBorder(),
                ),
                items: zones
                    .map(
                      (zone) =>
                          DropdownMenuItem(value: zone, child: Text(zone)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedZone = value),
                validator: (value) =>
                    value == null ? 'Please select a zone' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              selectedImageBytes != null
                  ? Image.memory(selectedImageBytes!, height: 150)
                  : const Text('No image selected'),

              TextButton(
                onPressed: pickImage,
                child: const Text('Select Image'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : submitForm,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
