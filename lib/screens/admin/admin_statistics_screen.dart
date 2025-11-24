import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

// IMPORT các màn hình admin
import '../login_screen.dart';
import 'admin_create_provider_screen.dart';
import 'admin_home_screen.dart';
import 'admin_users_screen.dart';
import 'admin_tour_screen.dart';
import 'admin_booking_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  List data = [];
  bool loading = false;

  final monthController = TextEditingController();
  final tourController = TextEditingController();
  String paymentFilter = "Tất cả";

  Future load() async {
    setState(() => loading = true);

    data = await AdminApiService.getStatistics(
      month: monthController.text.trim(),
      tourName: tourController.text.trim(),
      paymentStatus: paymentFilter,
    );

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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
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
  Widget drawerItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // =========================
  // ⭐ Drawer
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
              child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.indigo),
            ),
          ),
          drawerItem(
            icon: Icons.home,
            label: "Trang điều khiển",
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHomeScreen(user: {"email": "admin@example.com"}),
              ),
            ),
          ),
          drawerItem(
            icon: Icons.people,
            label: "Quản lý tài khoản",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
          ),
          drawerItem(
            icon: Icons.map,
            label: "Quản lý tour",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTourScreen())),
          ),
          drawerItem(
            icon: Icons.receipt_long,
            label: "Quản lý Booking",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingScreen())),
          ),
          drawerItem(
            icon: Icons.bar_chart,
            label: "Thống kê doanh thu",
            onTap: () => Navigator.pop(context),
          ),
          drawerItem(
            icon: Icons.person_add_alt_1,
            label: "Tạo Provider",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCreateProviderScreen())),
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

  // =========================
  // ⭐ Card thống kê (NÂNG CẤP)
  // =========================
  Widget statisticsCard(Map record) {
    bool isPaid = record["PaymentStatus"] == "Đã thanh toán";

    int adult = record["Adult"] ?? 0;
    int child = record["Child"] ?? 0;
    int guests = record["NumberOfGuests"] ?? (adult + child);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      elevation: 4,
      shadowColor: Colors.indigo.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Row 1: Icon + Tour name =====
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isPaid ? Colors.green : Colors.red,
                  child: Icon(
                    isPaid ? Icons.check_circle_outline : Icons.pending,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    record["TourName"],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== Customer =====
            Text(
              "👤 Khách hàng: ${record["CustomerName"]}",
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 4),

            // ===== Payment Status =====
            Text(
              "💳 Trạng thái: ${record["PaymentStatus"]}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),

            const SizedBox(height: 8),
            const Divider(),

            // ===== Guests Info =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.man, size: 20, color: Colors.indigo),
                    const SizedBox(width: 6),
                    Text("Người lớn: $adult", style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.child_care, size: 20, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text("Trẻ em: $child", style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.group, size: 20, color: Colors.green),
                    const SizedBox(width: 6),
                    Text("Tổng: $guests",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ⭐ BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê"),
        backgroundColor: Colors.indigo,
      ),
      drawer: buildDrawer(),
      body: Column(
        children: [
          // ===== Filter Section (đã làm đẹp) =====
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label nổi bật
                const Text(
                  "Bộ lọc thống kê",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 12),

                // TextField tháng
                TextField(
                  controller: monthController,
                  decoration: InputDecoration(
                    labelText: "Tháng (YYYY-MM)",
                    labelStyle: const TextStyle(color: Colors.indigo),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),

                // TextField tên tour
                TextField(
                  controller: tourController,
                  decoration: InputDecoration(
                    labelText: "Tên tour",
                    labelStyle: const TextStyle(color: Colors.indigo),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),

                // Dropdown
                DropdownButtonFormField(
                  value: paymentFilter,
                  decoration: InputDecoration(
                    labelText: "Trạng thái thanh toán",
                    labelStyle: const TextStyle(color: Colors.indigo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Tất cả", child: Text("Tất cả")),
                    DropdownMenuItem(value: "Đã thanh toán", child: Text("Đã thanh toán")),
                    DropdownMenuItem(value: "Chưa thanh toán", child: Text("Chưa thanh toán")),
                  ],
                  onChanged: (v) => setState(() => paymentFilter = v.toString()),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: load,
                    icon: const Icon(Icons.search),
                    label: const Text("Lọc kết quả"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== List thống kê =====
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                ? const Center(
              child: Text(
                "Không có dữ liệu!",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) => statisticsCard(data[i]),
            ),
          ),
        ],
      ),
    );
  }
}
