import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'booking_detail_screen.dart';

class BookingScreen extends StatefulWidget {
  final String tourID;
  final String tourName;
  final double tourPrice;
  final String tourImage;

  const BookingScreen({
    Key? key,
    required this.tourID,
    required this.tourName,
    required this.tourPrice,
    required this.tourImage,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int _adults = 1;
  int _children = 0;

  double get totalAmount =>
      (_adults * widget.tourPrice) + (_children * widget.tourPrice * 0.7);

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  // 🧾 Gửi request đặt tour
  Future<void> _bookTour() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Lấy userID từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString('userID');

      if (userID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bạn chưa đăng nhập!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final url = Uri.parse('http://10.0.2.2:3000/mobile/bookings');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userID": userID,
          "name": name,
          "email": email,
          "phone": phone,
          "address": address,
          "tourID": widget.tourID,
          "adults": _adults,
          "children": _children,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Đặt tour thành công!"),
            backgroundColor: Colors.green,
          ),
        );

        final bookingID = data['booking']?['bookingID'];

        if (bookingID != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(bookingID: bookingID),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Không tìm thấy mã đặt tour!"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("Lỗi server (${response.statusCode}): ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi kết nối: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt Tour"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.network(
                widget.tourImage,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 80),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tourName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Giá người lớn: ${formatCurrency(widget.tourPrice)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(height: 32),
                  const Text(
                    "Thông tin khách hàng",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField("Họ và tên", _nameController, Icons.person),
                  _buildTextField("Email", _emailController, Icons.email),
                  _buildTextField("Số điện thoại", _phoneController, Icons.phone),
                  _buildTextField("Địa chỉ", _addressController, Icons.home),
                  const SizedBox(height: 20),
                  const Text(
                    "Số lượng hành khách",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCounterRow("Người lớn", _adults, onIncrease: () {
                    setState(() => _adults++);
                  }, onDecrease: () {
                    if (_adults > 1) setState(() => _adults--);
                  }),
                  _buildCounterRow("Trẻ em", _children, onIncrease: () {
                    setState(() => _children++);
                  }, onDecrease: () {
                    if (_children > 0) setState(() => _children--);
                  }),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tạm tính:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency(totalAmount),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart_checkout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      label: const Text(
                        "Đặt tour ngay",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      onPressed: _bookTour,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.teal, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterRow(String title, int value,
      {required VoidCallback onIncrease, required VoidCallback onDecrease}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_circle_outline, color: Colors.teal),
              ),
              Text(value.toString(), style: const TextStyle(fontSize: 16)),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
