import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingDetailScreen extends StatefulWidget {
  final String bookingID;

  const BookingDetailScreen({Key? key, required this.bookingID})
      : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? bookingData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingDetail();
  }

  Future<void> fetchBookingDetail() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/bookings/${widget.bookingID}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bookingData = data;
          isLoading = false;
        });
      } else {
        throw Exception("Không lấy được dữ liệu (${response.statusCode})");
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (bookingData == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy dữ liệu đơn đặt.")),
      );
    }

    final flightList = bookingData!['Flights'] ?? [];
    final tourPrice = bookingData!['Price'] ?? 0;
    final flightPrice = flightList.isNotEmpty ? flightList[0]['Price'] ?? 0 : 0;
    final totalPrice = tourPrice + flightPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn đặt"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh tour
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'http://10.0.2.2:3000${bookingData!['ImageURL']}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin tour
            Text(
              bookingData!['TourName'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Thời gian lý tưởng: ${bookingData!['ThoiGianLyTuong'] ?? '---'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Thông tin khách hàng
            const Text(
              "Thông tin khách hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Họ tên: ${bookingData!['CustomerName']}"),
            Text("Email: ${bookingData!['Email']}"),
            Text("SĐT: ${bookingData!['Phone']}"),
            Text("Địa chỉ: ${bookingData!['Address']}"),
            const SizedBox(height: 16),

            // Thông tin chuyến bay
            if (flightList.isNotEmpty) ...[
              const Text(
                "Thông tin chuyến bay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...flightList.map((flight) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hãng bay: ${flight['Airline']}"),
                  Text(
                      "Đi từ: ${flight['DeparturePoint']} → ${flight['DestinationPoint']}"),
                  Text(
                      "Ngày đi: ${flight['DepartureDate'].toString().substring(0, 10)}"),
                  Text(
                      "Ngày về: ${flight['ReturnDate'].toString().substring(0, 10)}"),
                  Text(
                      "Giá vé: ${flight['Price'].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VND"),
                ],
              )),
              const SizedBox(height: 16),
            ],

            // Tổng tiền
            const Text(
              "Tổng tiền tạm tính",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              "${totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VND",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
