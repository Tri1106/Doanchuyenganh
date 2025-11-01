import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController tourIDController = TextEditingController();
  final TextEditingController adultsController = TextEditingController(text: '1');
  final TextEditingController childrenController = TextEditingController(text: '0');

  bool isLoading = false;
  String? message;

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = null;
    });

    const String apiUrl = "http://<YOUR_BACKEND_IP>:<PORT>/thanh-toan"; // 🔥 Thay IP + port backend

    final Map<String, dynamic> requestData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "tourID": tourIDController.text.trim(),
      "adults": adultsController.text.trim(),
      "children": childrenController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          message = data["message"];
        });

        // Nếu backend trả redirectUrl, có thể chuyển hướng
        if (data["redirectUrl"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Đi đến trang thanh toán...'),
          ));
        }
      } else {
        setState(() {
          message = "Lỗi: ${response.body}";
        });
      }
    } catch (err) {
      setState(() {
        message = "Không thể kết nối server: $err";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt tour du lịch")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Họ và tên"),
                validator: (v) => v!.isEmpty ? "Nhập họ tên" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Nhập email" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                validator: (v) => v!.isEmpty ? "Nhập số điện thoại" : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Địa chỉ"),
              ),
              TextFormField(
                controller: tourIDController,
                decoration: const InputDecoration(labelText: "Mã TourID"),
                validator: (v) => v!.isEmpty ? "Nhập TourID" : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: adultsController,
                      decoration: const InputDecoration(labelText: "Người lớn"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: childrenController,
                      decoration: const InputDecoration(labelText: "Trẻ em"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _submitBooking,
                icon: const Icon(Icons.check_circle_outline),
                label: isLoading
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Đặt tour ngay"),
              ),
              const SizedBox(height: 20),
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(
                    color: message!.contains("thành công") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
