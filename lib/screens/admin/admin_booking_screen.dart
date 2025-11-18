import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

class AdminBookingScreen extends StatefulWidget {
  @override
  State<AdminBookingScreen> createState() => _AdminBookingScreenState();
}

class _AdminBookingScreenState extends State<AdminBookingScreen> {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    bookings = await AdminApiService.getBookings();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, i) {
          final b = bookings[i];
          return Card(
            child: ListTile(
              title: Text(b['TourName']),
              subtitle:
              Text("${b['CustomerName']} - ${b['PaymentStatus']}"),
              trailing: ElevatedButton(
                onPressed: b["PaymentStatus"] == "Đã thanh toán"
                    ? null
                    : () async {
                  bool ok = await AdminApiService.confirmBooking(
                      b["BookingID"]);

                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Đã xác nhận!")));
                    load();
                  }
                },
                child: const Text("Xác nhận"),
              ),
            ),
          );
        });
  }
}
