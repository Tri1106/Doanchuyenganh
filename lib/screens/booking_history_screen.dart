import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = ApiService.getUserBookings();
  }

  Future<void> _refresh() async {
    setState(() {
      _bookings = ApiService.getUserBookings();
    });
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đặt tour"),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _bookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("Lỗi khi tải dữ liệu: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Chưa có đơn đặt tour nào."));
            }

            final bookings = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final bookingID = booking['BookingID'].toString();
                final tourName = booking['TourName'] ?? '';
                final bookingDate = booking['BookingDate'] ?? '';
                final paymentStatus = booking['PaymentStatus'] ?? 'Chưa thanh toán';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      tourName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Ngày đặt: ${formatDate(bookingDate)}"),
                        const SizedBox(height: 2),
                        Text(
                          "Trạng thái: $paymentStatus",
                          style: TextStyle(
                              color: paymentStatus == "Đã thanh toán"
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ],
                    ),
                    trailing: paymentStatus != "Đã thanh toán"
                        ? IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: "Hủy đơn",
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Xác nhận"),
                            content: const Text(
                                "Bạn có chắc muốn hủy đơn đặt này?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text("Đồng ý"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final success = await ApiService.cancelBooking(bookingID);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(success
                                    ? "Hủy đơn thành công"
                                    : "Hủy đơn thất bại")),
                          );
                          _refresh();
                        }
                      },
                    )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
