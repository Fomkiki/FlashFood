import 'dart:typed_data';
import 'package:frontend/pages/main_res_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/restaurant_service.dart';

class EditResPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String ImgUrl;

  const EditResPage({
    super.key,
    required this.restaurant,
    required this.ImgUrl,
  });

  @override
  State<EditResPage> createState() => _EditResPageState();
}

class _EditResPageState extends State<EditResPage> {
  late Map<String, dynamic> newRestaurant;
  late String newImgUrl;

  @override
  void initState() {
    super.initState();
    newRestaurant = Map.from(widget.restaurant);
    newImgUrl = widget.ImgUrl;
  }

  Future<void> reloadData() async {
    final service = RestaurantService();
    final newData = await service.getRestaurants(widget.restaurant['id']);

    setState(() {
      newRestaurant = Map.from(newData);
      const String baseImageUrl = "http://10.0.2.2:5000/";
      final String imagePath = newRestaurant['img_url'].replaceAll("\\", "/");
      newImgUrl = baseImageUrl + imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Restaurant'),
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
              SizedBox(height: 18),
              Center(
                child: Text(
                  newRestaurant['name_res'],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Address: ${newRestaurant['address']}",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                "Phone: ${newRestaurant['phone']}",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                "Opening : ${newRestaurant['open_time']}-${newRestaurant['close_time']}",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                "status: ${newRestaurant['status_res']}",
                style: TextStyle(
                  fontSize: 20,
                  color: newRestaurant['status_res'] == 'open'
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
                          child: EditCard(
                            restaurant: newRestaurant,
                            ImgUrl: newImgUrl,
                          ),
                        );
                      },
                    );
                    print(result);
                    if (result == true) {
                      await reloadData();
                    }
                  },
                  child: const Text(
                    'Edit restaurant',
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
  final Map<String, dynamic> restaurant;
  final String ImgUrl;
  const EditCard({super.key, required this.restaurant, required this.ImgUrl});

  @override
  State<EditCard> createState() => _EditCardState();
}

class _EditCardState extends State<EditCard> {
  late TextEditingController name_resController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController open_timeController;
  late TextEditingController close_timeController;
  String? selectedStatus;
  final List<String> status = ['open', 'close'];
  Uint8List? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    name_resController = TextEditingController(
      text: widget.restaurant['name_res'],
    );
    addressController = TextEditingController(
      text: widget.restaurant['address'],
    );
    phoneController = TextEditingController(text: widget.restaurant['phone']);
    open_timeController = TextEditingController(
      text: widget.restaurant['open_time'],
    );
    close_timeController = TextEditingController(
      text: widget.restaurant['close_time'],
    );
    selectedStatus = widget.restaurant['status_res'];
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
      "name_res": name_resController.text,
      "address": addressController.text,
      "phone": phoneController.text,
      "open_time": open_timeController.text,
      "close_time": close_timeController.text,
      "status_res": selectedStatus ?? "",
    };

    final service = RestaurantService();

    final success = await service.updateRestaurant(
      widget.restaurant['id'],
      fields,
      selectedImage,
    );

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update restaurant')),
      );
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
              controller: name_resController,
              decoration: const InputDecoration(
                labelText: 'Name of Restaurant',
              ),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: open_timeController,
              decoration: const InputDecoration(labelText: 'Opening Time'),
            ),
            TextField(
              controller: close_timeController,
              decoration: const InputDecoration(labelText: 'Closing Time'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: InputDecoration(
                labelText: "Status of Restaurant",
                border: const OutlineInputBorder(),
              ),
              items: status
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedStatus = value),
              validator: (value) =>
                  value == null ? 'Please select a status' : null,
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
                'Update Restaurant',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
