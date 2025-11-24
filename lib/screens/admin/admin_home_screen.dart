import 'package:doanchuyennganh/screens/admin/admin_create_provider_screen.dart';
import 'package:flutter/material.dart';

// IMPORT CÁC MÀN HÌNH ADMIN
import 'admin_users_screen.dart';
import 'admin_tour_screen.dart';
import 'admin_statistics_screen.dart';
import 'admin_booking_screen.dart';
import 'admin_dashboard_screen.dart';
import '../login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({super.key, required this.user});

  // ======================================================
  // ⭐ COMPONENT MỤC TRONG DASHBOARD
  // ======================================================
  Widget buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.indigo, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ================
  // ⭐ Logout Dialog
  // ================
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  // ================
  // ⭐ Drawer Item
  // ================
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

  // ================
  // ⭐ UI chính
  // ================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f5f9),

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 1,
        title: const Text("Admin Dashboard"),
      ),

      // =========================
      // ⭐ DRAWER MENU giống Provider
      // =========================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              accountName: Text(
                "Admin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user["email"] ?? ""),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings,
                    size: 40, color: Colors.indigo),
              ),
            ),

            drawerItem(
              icon: Icons.home,
              label: "Trang điều khiển",
              onTap: () => Navigator.pop(context),
            ),
            drawerItem(
              icon: Icons.people,
              label: "Quản lý tài khoản",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminUsersScreen()),
              ),
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
      ),

      // BODY DASHBOARD NHƯ CŨ
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Xin chào, Admin!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Chọn chức năng để bắt đầu",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            buildSection(
              icon: Icons.people,
              title: "Quản lý tài khoản",
              subtitle: "User & Provider",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminUsersScreen()),
                );
              },
            ),

            buildSection(
              icon: Icons.map_rounded,
              title: "Quản lý tour du lịch",
              subtitle: "Chỉnh sửa & duyệt tour",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminTourScreen()),
                );
              },
            ),

            buildSection(
              icon: Icons.bar_chart_rounded,
              title: "Doanh thu & thống kê",
              subtitle: "Xem báo cáo theo tháng",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminStatisticsScreen()),
                );
              },
            ),

            buildSection(
              icon: Icons.person_add_alt_1,
              title: "Tạo Provider mới",
              subtitle: "Thêm nhà cung cấp dịch vụ",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminCreateProviderScreen()),
                );
              },
            ),

            buildSection(
              icon: Icons.receipt_long,
              title: "Quản lý Booking",
              subtitle: "Xem & duyệt đơn đặt tour",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminBookingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
