import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// IMPORT các màn hình Admin
import 'admin_home_screen.dart';
import 'admin_users_screen.dart';
import 'admin_tour_screen.dart';
import 'admin_statistics_screen.dart';
import 'admin_booking_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminCreateProviderScreen extends StatefulWidget {
  const AdminCreateProviderScreen({super.key});

  @override
  State<AdminCreateProviderScreen> createState() => _AdminCreateProviderScreenState();
}

class _AdminCreateProviderScreenState extends State<AdminCreateProviderScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  Future<void> createProvider() async {
    if (fullName.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => loading = true);

    final url = Uri.parse("http://10.0.2.2:3000/register-provider");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullName": fullName.text,
        "email": email.text,
        "phone": phone.text,
        "password": password.text,
      }),
    );

    setState(() => loading = false);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo provider thành công!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo provider thất bại!")),
      );
    }
  }

  // --------------------
  // Drawer Menu đẹp + fix lỗi
  // --------------------
  Drawer buildAdminDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              "Administrator",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("admin@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, size: 38, color: Colors.indigo),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          drawerItem(
            icon: Icons.home,
            label: "Trang chủ",
            screen: const AdminHomeScreen(user: {"email": "admin@example.com"}),
          ),
          drawerItem(
            icon: Icons.people,
            label: "Quản lý Users",
            screen: AdminUsersScreen(),
          ),
          drawerItem(
            icon: Icons.map,
            label: "Quản lý Tour",
            screen: AdminTourScreen(),
          ),
          drawerItem(
            icon: Icons.receipt_long,
            label: "Quản lý Booking",
            screen: const AdminBookingScreen(),
          ),
          drawerItem(
            icon: Icons.bar_chart,
            label: "Thống kê",
            screen: const AdminStatisticsScreen(),
          ),
          drawerItem(
            icon: Icons.person_add_alt_1,
            label: "Tạo Provider",
            screen: const AdminCreateProviderScreen(),
          ),
        ],
      ),
    );
  }

  ListTile drawerItem({
    required IconData icon,
    required String label,
    required Widget screen,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }

  // Beautiful textfield
  InputDecoration buildInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAdminDrawer(),
      appBar: AppBar(
        title: const Text("Tạo Provider mới"),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            TextField(controller: fullName, decoration: buildInput("Tên Provider")),
            const SizedBox(height: 16),

            TextField(controller: email, decoration: buildInput("Email")),
            const SizedBox(height: 16),

            TextField(controller: phone, decoration: buildInput("Số điện thoại")),
            const SizedBox(height: 16),

            TextField(
              controller: password,
              obscureText: true,
              decoration: buildInput("Mật khẩu"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : createProvider,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Tạo Provider",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
