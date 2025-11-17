import 'package:flutter/material.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key, required Map<String, dynamic> user});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int selectedIndex = 0;

  final List<String> menuTitles = [
    "Thêm Tour",
    "Quản Lý Tour",
    "Xem Đơn Đặt",
    "Xác Nhận Tour",
    "Quản Lý KS/Vé MB",
    "Quản Lý Lịch Trình",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menuTitles[selectedIndex]),
        backgroundColor: Colors.indigo,
      ),

      // Drawer menu như web nhưng chuẩn mobile
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                "Provider Panel",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),

            _buildMenuItem(Icons.add, "Thêm Tour", 0),
            _buildMenuItem(Icons.edit, "Quản Lý Tour", 1),
            _buildMenuItem(Icons.receipt_long, "Xem Đơn Đặt", 2),
            _buildMenuItem(Icons.check_circle, "Xác Nhận Tour", 3),
            _buildMenuItem(Icons.hotel, "Quản Lý KS/Vé MB", 4),
            _buildMenuItem(Icons.calendar_month, "Quản Lý Lịch Trình", 5),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Đăng Xuất"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
      ),

      body: _buildContent(),
    );
  }

  // Drawer menu item component
  Widget _buildMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      selected: selectedIndex == index,
      onTap: () {
        setState(() => selectedIndex = index);
        Navigator.pop(context); // đóng Drawer
      },
    );
  }

  // Nội dung chính của từng menu
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _addTourUI();
      case 1:
        return _manageTourUI();
      case 2:
        return _viewBookingsUI();
      case 3:
        return _confirmTourUI();
      case 4:
        return _manageHotelFlightUI();
      case 5:
        return _manageScheduleUI();
      default:
        return const Center(child: Text("Lỗi không xác định"));
    }
  }

  // ---------------------- UI for each module ----------------------

  Widget _addTourUI() {
    return const Center(
      child: Text("Giao diện Thêm Tour"),
    );
  }

  Widget _manageTourUI() {
    return const Center(
      child: Text("Quản lý Tour"),
    );
  }

  Widget _viewBookingsUI() {
    return const Center(
      child: Text("Xem Đơn Đặt"),
    );
  }

  Widget _confirmTourUI() {
    return const Center(
      child: Text("Xác Nhận Tour"),
    );
  }

  Widget _manageHotelFlightUI() {
    return const Center(
      child: Text("Quản lý Khách Sạn & Vé Máy Bay"),
    );
  }

  Widget _manageScheduleUI() {
    return const Center(
      child: Text("Quản lý Lịch Trình Tour"),
    );
  }
}
