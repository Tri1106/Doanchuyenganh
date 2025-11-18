import 'package:flutter/material.dart';
import 'admin_booking_screen.dart';
import 'admin_users_screen.dart';
import 'admin_tour_screen.dart';
import 'admin_statistics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int index = 0;

  final screens = [
    AdminBookingScreen(),
    AdminUsersScreen(),
    AdminTourScreen(),
    AdminStatisticsScreen(),
  ];

  final menuNames = [
    "Quản lý Booking",
    "Quản lý User",
    "Quản lý Tour",
    "Thống kê",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(menuNames[index])),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text("Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
            _tile(Icons.list, "Quản lý Booking", 0),
            _tile(Icons.people, "Quản lý User", 1),
            _tile(Icons.tour, "Quản lý Tour", 2),
            _tile(Icons.bar_chart, "Thống kê", 3),
          ],
        ),
      ),
      body: screens[index],
    );
  }

  ListTile _tile(IconData icon, String title, int i) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: index == i,
      onTap: () {
        setState(() => index = i);
        Navigator.pop(context);
      },
    );
  }
}
