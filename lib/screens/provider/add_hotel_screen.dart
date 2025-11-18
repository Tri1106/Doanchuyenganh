import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final picker = ImagePicker();
  File? image;

  final tourID = TextEditingController();
  final hotelName = TextEditingController();
  final location = TextEditingController();
  final price = TextEditingController();

  Future pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => image = File(file.path));
  }

  void save() async {
    final data = {
      "tourID": tourID.text,
      "hotelName": hotelName.text,
      "location": location.text,
      "pricePerNight": price.text,
    };

    bool ok = await ApiService.addHotel(data, image);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm khách sạn thành công!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Khách Sạn")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: image == null
                  ? Container(
                height: 180,
                color: Colors.grey.shade300,
                child: const Center(child: Text("Chọn ảnh khách sạn")),
              )
                  : Image.file(image!, height: 180),
            ),
            _input("Tour ID", tourID),
            _input("Tên khách sạn", hotelName),
            _input("Địa điểm", location),
            _input("Giá / Đêm", price, type: TextInputType.number),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: save, child: const Text("Lưu")),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
