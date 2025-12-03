import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentMethodScreen extends StatelessWidget {
  final String bookingID;
  final double totalAmount;

  const PaymentMethodScreen({
    Key? key,
    required this.bookingID,
    required this.totalAmount,
  }) : super(key: key);

  String formatCurrency(double amount) {
    final f = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return f.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phương thức thanh toán"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Thanh toán đơn hàng",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
              ),
              const SizedBox(height: 20),

              // 🔥 MÃ ĐẶT CHỖ
              _infoRow("Mã đặt chỗ:", bookingID),

              const SizedBox(height: 10),

              // 🔥 TỔNG TIỀN
              _infoRow("Tổng tiền:", formatCurrency(totalAmount),
                  valueColor: Colors.red),

              const SizedBox(height: 30),

              const Text(
                "Chuyển khoản ngân hàng",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              const SizedBox(height: 15),

              // 🔥 Thông tin ngân hàng
              _bankRow("Ngân hàng:", "Vietcombank"),
              _bankRow("Số tài khoản:", "0259456136"),
              _bankRow("Chủ tài khoản:", "Công ty Du lịch"),

              const SizedBox(height: 10),
              const Text(
                "Nội dung chuyển khoản:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Text(
                bookingID,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),

              const SizedBox(height: 20),

              // 🔔 Lưu ý
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(width: 5, color: Colors.orange.shade700),
                  ),
                ),
                child: const Text(
                  "Vui lòng kiểm tra kỹ thông tin trước khi chuyển khoản.\n"
                      "Mọi sai sót có thể gây chậm trễ xác nhận đơn hàng.",
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, {Color valueColor = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _bankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
