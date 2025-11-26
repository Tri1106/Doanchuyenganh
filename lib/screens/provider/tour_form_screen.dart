// screens/tour/tour_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'tour_list_screen.dart';
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
      name.text = widget.tour!["TourName"] ?? '';
      des.text = widget.tour!["Destination"] ?? '';
      price.text = widget.tour!["Price"].toString();
      seats.text = widget.tour!["SoCho"].toString();
      dtq.text = widget.tour!["DiemThamQuan"] ?? '';
      amthuc.text = widget.tour!["AmThuc"] ?? '';
      dtth.text = widget.tour!["DoiTuongThichHop"] ?? '';
      tgl.text = widget.tour!["ThoiGianLyTuong"] ?? '';
      pt.text = widget.tour!["PhuongTien"] ?? '';
      km.text = widget.tour!["KhuyenMai"] ?? '';
    }
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  void save() async {
    try {
      if (!widget.isEdit && image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn ảnh cho tour")),
        );
        return;
      }

      final data = {
        "tourName": name.text.trim(),
        "destination": des.text.trim(),
        "price": int.tryParse(price.text) ?? 0,
        "seats": int.tryParse(seats.text) ?? 0,
        "diemThamQuan": dtq.text.trim(),
        "amThuc": amthuc.text.trim(),
        "doiTuongThichHop": dtth.text.trim(),
        "thoiGianLyTuong": tgl.text.trim(),
        "phuongTien": pt.text.trim(),
        "khuyenMai": km.text.trim(),
      };

      bool ok;

      if (widget.isEdit) {
        final id = widget.tour!["TourID"].toString();  // FIX key
        ok = await ApiService.updateTour(id, data);
      } else {
        ok = await ApiService.addTour(data, image);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? "Lưu thành công!" : "API lỗi!")),
      );

      if (ok) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TourListScreen()),
        );
      }

    } catch (e) {
      print("🔥 LỖI FORM: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  Widget buildInput(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final oldImageUrl = widget.isEdit && widget.tour != null
        ? widget.tour!["ImageURL"]     // FIX key
        : null;

    final imageUrl = oldImageUrl == null
        ? null
        : "${ApiService.base}${oldImageUrl.toString().replaceFirst(RegExp(r'^/+'), '')}";

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? "Sửa tour" : "Thêm tour mới")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: image != null
                  ? Image.file(image!, height: 200, fit: BoxFit.cover)
                  : imageUrl != null
                  ? Image.network(imageUrl, height: 200, fit: BoxFit.cover)
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
            ElevatedButton(
              onPressed: save,
              child: const Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }
}
