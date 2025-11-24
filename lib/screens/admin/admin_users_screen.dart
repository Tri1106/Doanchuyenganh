import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../login_screen.dart';
import 'admin_create_provider_screen.dart';
import 'admin_home_screen.dart';
import 'admin_tour_screen.dart';
import 'admin_statistics_screen.dart';
import 'admin_booking_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    users = await AdminApiService.getUsers();
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
  // ⭐ DRAWER CHUNG CHO ADMIN
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
            accountEmail: const Text("admin@example.com"), // có thể sửa thành email thật nếu muốn
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
                    user: {"email": "admin@example.com"}), // nếu bạn cần truyền user info
              ),
            ),
          ),
          drawerItem(
            icon: Icons.people,
            label: "Quản lý tài khoản",
            onTap: () => Navigator.pop(context),
          ),
          drawerItem(
            icon: Icons.map,
            label: "Quản lý tour",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminTourScreen()),
            ),
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
        title: const Text("Quản lý người dùng"),
        backgroundColor: Colors.indigo,
      ),
      drawer: buildDrawer(), // thêm drawer
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, i) {
          final u = users[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.indigo.shade800,
                child: Text(
                  u["FullName"][0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                u["FullName"],
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                u["Email"],
                style: TextStyle(color: Colors.grey.shade700),
              ),
              trailing: PopupMenuButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "delete",
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Xóa người dùng"),
                      ],
                    ),
                  )
                ],
                onSelected: (value) async {
                  if (value == "delete") {
                    bool ok =
                    await AdminApiService.deleteUser(u["UserID"]);
                    if (ok) load();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
