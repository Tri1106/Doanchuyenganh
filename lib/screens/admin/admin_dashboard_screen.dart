import 'package:flutter/material.dart';
import '../login_screen.dart';
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
      // ==========================
      // APP BAR
      // ==========================
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          menuNames[index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),

      // ==========================
      // DRAWER MENU
      // ==========================
      drawer: buildAdminMenu(context),

      // ==========================
      // MAIN CONTENT
      // ==========================
      body: screens[index],
    );
  }

  // ==================================================
  // ⭐ DRAWER MENU ĐẸP – CHUẨN MOBILE
  // ==================================================
  Drawer buildAdminMenu(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            accountName: const Text("Administrator"),
            accountEmail: const Text("admin@system.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.indigo),
            ),
          ),

          // LIST ITEM
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                drawerItem(Icons.book_online, "Quản lý Booking", 0),
                drawerItem(Icons.people, "Quản lý User", 1),
                drawerItem(Icons.tour, "Quản lý Tour", 2),
                drawerItem(Icons.bar_chart, "Thống kê", 3),
              ],
            ),
          ),

          const Divider(height: 1),

          // LOGOUT
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // ==================================================
  // ⭐ ITEM MENU CÓ HIGHLIGHT – ICON – BO TRÒN
  // ==================================================
  Widget drawerItem(IconData icon, String title, int i) {
    final bool selected = index == i;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => index = i);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.indigo.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? Colors.indigo : Colors.black87,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: selected ? Colors.indigo : Colors.black87,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
