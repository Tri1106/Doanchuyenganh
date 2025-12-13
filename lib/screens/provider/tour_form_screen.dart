// screens/tour/tour_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'tour_list_screen.dart';

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

  final nameController = TextEditingController();
  final desController = TextEditingController();
  final priceController = TextEditingController();
  final seatsController = TextEditingController();
  final dtqController = TextEditingController();
  final amthucController = TextEditingController();
  final dtthController = TextEditingController();
  final tglController = TextEditingController();
  final ptController = TextEditingController();
  final kmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.tour != null) {
      nameController.text = widget.tour!["TourName"] ?? '';
      desController.text = widget.tour!["Destination"] ?? '';
      priceController.text = widget.tour!["Price"]?.toString() ?? '';
      seatsController.text = widget.tour!["SoCho"]?.toString() ?? '';
      dtqController.text = widget.tour!["DiemThamQuan"] ?? '';
      amthucController.text = widget.tour!["AmThuc"] ?? '';
      dtthController.text = widget.tour!["DoiTuongThichHop"] ?? '';
      tglController.text = widget.tour!["ThoiGianLyTuong"] ?? '';
      ptController.text = widget.tour!["PhuongTien"] ?? '';
      kmController.text = widget.tour!["KhuyenMai"] ?? '';
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
        "tourName": nameController.text.trim(),
        "destination": desController.text.trim(),
        "price": int.tryParse(priceController.text) ?? 0,
        "seats": int.tryParse(seatsController.text) ?? 0,
        "diemThamQuan": dtqController.text.trim(),
        "amThuc": amthucController.text.trim(),
        "doiTuongThichHop": dtthController.text.trim(),
        "thoiGianLyTuong": tglController.text.trim(),
        "phuongTien": ptController.text.trim(),
        "khuyenMai": kmController.text.trim(),
      };

      bool ok = false;

      if (widget.isEdit) {
        final id = widget.tour!["TourID"].toString();

        // Nếu chọn ảnh mới, upload trước và lấy URL
        if (image != null) {
          final uploadedUrl = await ApiService.uploadTourImage(id, image!);
          if (uploadedUrl != null) {
            data["ImageURL"] = uploadedUrl;
          }
        }

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ảnh cũ nếu edit và chưa chọn ảnh mới
    final oldImageUrl = widget.isEdit && widget.tour != null
        ? widget.tour!["ImageURL"]
        : null;

    final displayImage = image != null
        ? FileImage(image!)
        : (oldImageUrl != null
        ? NetworkImage(
        "${ApiService.base}/${oldImageUrl.toString().replaceFirst(RegExp(r'^/+'), '')}")
        : null);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? "Sửa tour" : "Thêm tour mới")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                ),
                child: displayImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: displayImage is FileImage
                      ? Image.file(image!, fit: BoxFit.cover)
                      : Image.network(
                    "${ApiService.base}/${oldImageUrl.toString().replaceFirst(RegExp(r'^/+'), '')}",
                    fit: BoxFit.cover,
                  ),
                )
                    : const Center(child: Text("Chọn ảnh")),
              ),
            ),
            buildInput("Tên tour", nameController),
            buildInput("Điểm đến", desController),
            buildInput("Giá", priceController, type: TextInputType.number),
            buildInput("Số chỗ", seatsController, type: TextInputType.number),
            buildInput("Điểm tham quan", dtqController),
            buildInput("Ẩm thực", amthucController),
            buildInput("Đối tượng phù hợp", dtthController),
            buildInput("Thời gian lý tưởng", tglController),
            buildInput("Phương tiện", ptController),
            buildInput("Khuyến mãi", kmController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
