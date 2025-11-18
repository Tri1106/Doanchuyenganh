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

  // --- COMPONENT CỦA TỪNG MỤC ---
  Widget buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.teal, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style:
                      const TextStyle(fontSize: 14, color: Colors.black54),
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 18, color: Colors.black45)
            ],
          ),
        ),
      ),
    );
  }

  // Hàm logout
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy")),
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f3f6),

      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Trang điều khiển",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            // 1. Quản lý tài khoản
            buildSection(
              icon: Icons.people,
              title: "Quản lý tài khoản",
              subtitle: "Danh sách user & provider",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminUsersScreen()),
                );
              },
            ),

            // 2. Quản lý tour
            buildSection(
              icon: Icons.map,
              title: "Quản lý tour",
              subtitle: "Duyệt & chỉnh sửa thông tin tour",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminTourScreen()),
                );
              },
            ),

            // 3. Doanh thu / Thống kê
            buildSection(
              icon: Icons.bar_chart,
              title: "Quản lý doanh thu",
              subtitle: "Thống kê theo tháng",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminStatisticsScreen()),
                );
              },
            ),

            // 4. Tạo Provider
            buildSection(
              icon: Icons.person_add_alt_1,
              title: "Tạo tài khoản Provider",
              subtitle: "Thêm provider mới",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminDashboardScreen()),
                );
              },
            ),

            // 5. Quản lý đơn đặt tour
            buildSection(
              icon: Icons.receipt_long,
              title: "Quản lý đơn đặt tour",
              subtitle: "Xem và duyệt booking",
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
