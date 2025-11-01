import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? booking;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingDetail();
  }

  Future<void> fetchBookingDetail() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/bookings/${widget.bookingId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          booking = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Không thể tải thông tin đặt tour');
      }
    } catch (e) {
      print("❌ Lỗi khi lấy booking: $e");
      setState(() => isLoading = false);
    }
  }

  String formatPrice(double? price) {
    if (price == null) return "Liên hệ";
    final formatter = NumberFormat('#,###', 'vi_VN');
    return "${formatter.format(price)} đ";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy thông tin đặt tour")),
      );
    }

    final flights = booking!['Flights'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đặt tour"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("🧾 Thông tin đặt chỗ"),
            _infoRow("Mã đặt chỗ", booking!['BookingID']),
            _infoRow("Ngày đặt", booking!['BookingDate']),
            const SizedBox(height: 10),
            const Divider(),

            _sectionTitle("👤 Thông tin khách hàng"),
            _infoRow("Tên khách hàng", booking!['CustomerName']),
            _infoRow("Email", booking!['Email']),
            _infoRow("SĐT", booking!['Phone']),
            _infoRow("Địa chỉ", booking!['Address']),
            const SizedBox(height: 10),
            const Divider(),

            _sectionTitle("🏝 Thông tin tour"),
            _infoRow("Tên tour", booking!['TourName']),
            _infoRow("Thời gian lý tưởng", booking!['ThoiGianLyTuong']),
            _infoRow("Giá tour", formatPrice(double.tryParse('${booking!['Price']}'))),
            const SizedBox(height: 10),

            if (booking!['ImageURL'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  booking!['ImageURL'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 100),
                ),
              ),

            const SizedBox(height: 20),
            const Divider(),

            if (flights.isNotEmpty) ...[
              _sectionTitle("✈️ Chuyến bay"),
              ...flights.map((f) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.flight, color: Colors.teal),
                  title: Text(f['Airline'] ?? ''),
                  subtitle: Text(
                      "${f['DeparturePoint']} → ${f['DestinationPoint']}\nNgày đi: ${f['DepartureDate'] ?? ''}\nNgày về: ${f['ReturnDate'] ?? ''}"),
                  trailing: Text(
                    formatPrice(double.tryParse('${f['Price']}')),
                    style: const TextStyle(color: Colors.teal),
                  ),
                ),
              )),
            ],

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Đặt tour thành công!")),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text("Xác nhận đặt tour"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value?.toString() ?? '')),
        ],
      ),
    );
  }
}
