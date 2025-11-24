import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../login_screen.dart';
import 'admin_create_provider_screen.dart';
import 'admin_home_screen.dart';
import 'admin_users_screen.dart';
import 'admin_statistics_screen.dart';
import 'admin_booking_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminTourScreen extends StatefulWidget {
  const AdminTourScreen({super.key});

  @override
  State<AdminTourScreen> createState() => _AdminTourScreenState();
}

class _AdminTourScreenState extends State<AdminTourScreen> {
  List tours = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    tours = await AdminApiService.getTours();
    setState(() => loading = false);
  }

  // =========================
  // ⭐ Logout Dialog
  // =========================
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  // =========================
  // ⭐ Drawer Item
  // =========================
  Widget drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // =========================
  // ⭐ Drawer chung cho admin
  // =========================
  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            accountName: const Text(
              "Admin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("admin@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings,
                  size: 40, color: Colors.indigo),
            ),
          ),
          drawerItem(
            icon: Icons.home,
            label: "Trang điều khiển",
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHomeScreen(
                    user: {"email": "admin@example.com"}),
              ),
            ),
          ),
          drawerItem(
            icon: Icons.people,
            label: "Quản lý tài khoản",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            ),
          ),
          drawerItem(
            icon: Icons.map,
            label: "Quản lý tour",
            onTap: () => Navigator.pop(context),
          ),
          drawerItem(
            icon: Icons.receipt_long,
            label: "Quản lý Booking",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminBookingScreen()),
            ),
          ),
          drawerItem(
            icon: Icons.bar_chart,
            label: "Thống kê doanh thu",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminStatisticsScreen()),
            ),
          ),
          drawerItem(
            icon: Icons.person_add_alt_1,
            label: "Tạo Provider",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminCreateProviderScreen()),
            ),
          ),
          const Divider(),
          drawerItem(
            icon: Icons.logout,
            label: "Đăng xuất",
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý tour"),
        backgroundColor: Colors.indigo,
      ),
      drawer: buildDrawer(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tours.length,
        itemBuilder: (context, i) {
          final t = tours[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              title: Text(t["TourName"]),
              subtitle: Text("Giá: ${t["Price"]}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool ok =
                  await AdminApiService.deleteTour(t["TourName"]);
                  if (ok) load();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
