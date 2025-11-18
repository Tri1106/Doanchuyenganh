import 'package:flutter/material.dart';
import 'add_hotel_screen.dart';
import 'add_flight_screen.dart';

class HotelFlightManagerScreen extends StatelessWidget {
  const HotelFlightManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản Lý Khách Sạn & Vé Máy Bay")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const AddHotelScreen(),
                    ));
              },
              child: const Text("➕ Thêm Khách Sạn"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const AddFlightScreen(),
                    ));
              },
              child: const Text("✈️ Thêm Vé Máy Bay"),
            ),
          ],
        ),
      ),
    );
  }
}
