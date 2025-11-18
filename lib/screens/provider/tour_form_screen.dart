import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class TourFormScreen extends StatefulWidget {
  final bool isEdit;
  final Map? tour;

  const TourFormScreen({super.key, required this.isEdit, this.tour});

  @override
  State<TourFormScreen> createState() => _TourFormScreenState();
}

class _TourFormScreenState extends State<TourFormScreen> {
  final picker = ImagePicker();
  File? image;

  final name = TextEditingController();
  final des = TextEditingController();
  final price = TextEditingController();
  final seats = TextEditingController();
  final dtq = TextEditingController();
  final amthuc = TextEditingController();
  final dtth = TextEditingController();
  final tgl = TextEditingController();
  final pt = TextEditingController();
  final km = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.tour != null) {
      name.text = widget.tour!["TourName"];
      des.text = widget.tour!["Destination"];
      price.text = widget.tour!["Price"].toString();
      seats.text = widget.tour!["SoCho"].toString();
    }
  }

  Future pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => image = File(file.path));
  }

  void save() async {
    final data = {
      "tourName": name.text,
      "destination": des.text,
      "price": price.text,
      "seats": seats.text,
      "diemThamQuan": dtq.text,
      "amThuc": amthuc.text,
      "doiTuongThichHop": dtth.text,
      "thoiGianLyTuong": tgl.text,
      "phuongTien": pt.text,
      "khuyenMai": km.text,
    };

    bool ok = false;

    if (widget.isEdit) {
      ok = await ApiService.updateTour(widget.tour!["TourID"], data);
    } else {
      ok = await ApiService.addTour(data, image);
    }

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thành công!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? "Sửa tour" : "Thêm tour mới"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          GestureDetector(
            onTap: pickImage,
            child: image != null
                ? Image.file(image!, height: 200)
                : Container(
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(child: Text("Chọn ảnh")),
            ),
          ),
          buildInput("Tên tour", name),
          buildInput("Điểm đến", des),
          buildInput("Giá", price, type: TextInputType.number),
          buildInput("Số chỗ", seats, type: TextInputType.number),
          buildInput("Điểm tham quan", dtq),
          buildInput("Ẩm thực", amthuc),
          buildInput("Đối tượng phù hợp", dtth),
          buildInput("Thời gian lý tưởng", tgl),
          buildInput("Phương tiện", pt),
          buildInput("Khuyến mãi", km),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: save, child: const Text("Lưu")),
        ]),
      ),
    );
  }

  Widget buildInput(String label, TextEditingController c,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
