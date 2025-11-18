import 'package:flutter/material.dart';
import 'tour_form_screen.dart';
import 'tour_list_screen.dart';
import 'hotel_flight_manager_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProviderDashboardScreen({
    super.key,
    required this.user,
  });

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
            _buildMenuItem(Icons.list, "Quản Lý Tour", 1),
            _buildMenuItem(Icons.receipt_long, "Xem Đơn Đặt", 2),
            _buildMenuItem(Icons.check_circle, "Xác Nhận Tour", 3),
            _buildMenuItem(Icons.hotel, "Quản Lý KS/Vé MB", 4),
            _buildMenuItem(Icons.calendar_month, "Quản Lý Lịch Trình", 5),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Đăng Xuất"),
              onTap: () {
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
      ),

      body: _buildContent(),
    );
  }

  // ================================
  // Drawer menu item
  // ================================
  Widget _buildMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedIndex == index,
      onTap: () {
        setState(() => selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  // ================================
  // MAIN CONTENT AREA
  // ================================
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return const TourFormScreen(isEdit: false);

      case 1:
        return const TourListScreen();

      case 4:
        return const HotelFlightManagerScreen();

      case 5:
      // 🔥 ĐÚNG NHẤT: Chọn tour trước khi xem lịch trình
        return const TourListScreen();

      default:
        return const Center(child: Text("Chức năng đang phát triển"));
    }
  }
}
