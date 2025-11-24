import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

// IMPORT các màn hình admin
import '../login_screen.dart';
import 'admin_create_provider_screen.dart';
import 'admin_home_screen.dart';
import 'admin_users_screen.dart';
import 'admin_tour_screen.dart';
import 'admin_statistics_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminBookingScreen extends StatefulWidget {
  const AdminBookingScreen({super.key});

  @override
  State<AdminBookingScreen> createState() => _AdminBookingScreenState();
}

class _AdminBookingScreenState extends State<AdminBookingScreen> {
  List bookings = [];
  List filteredBookings = [];
  bool loading = true;

  // Bộ lọc
  final TextEditingController monthController = TextEditingController();
  final TextEditingController tourNameController = TextEditingController();
  String paymentFilter = "Tất cả";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    setState(() => loading = true);

    bookings = await AdminApiService.getBookings();
    filteredBookings = bookings;

    setState(() => loading = false);
  }

  // =========================
  // ⭐ Lọc dữ liệu
  // =========================
  void filter() {
    String month = monthController.text.trim();
    String tourName = tourNameController.text.trim().toLowerCase();

    setState(() {
      filteredBookings = bookings.where((b) {
        bool match = true;

        if (month.isNotEmpty) {
          match = match && b["BookingDate"].toString().startsWith(month);
        }

        if (tourName.isNotEmpty) {
          match = match &&
              b["TourName"].toString().toLowerCase().contains(tourName);
        }

        if (paymentFilter == "Đã thanh toán") {
          match = match && b["PaymentStatus"] == "Đã thanh toán";
        } else if (paymentFilter == "Chưa thanh toán") {
          match = match && b["PaymentStatus"] != "Đã thanh toán";
        }

        return match;
      }).toList();
    });
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
          ),
        ],
      ),
    );
  }

  // =========================
  // ⭐ Drawer Item
  // =========================
  Widget drawerItem(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // =========================
  // ⭐ Drawer (GIỮ NGUYÊN)
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
                builder: (_) =>
                const AdminHomeScreen(user: {"email": "admin@example.com"}),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminTourScreen()),
            ),
          ),
          drawerItem(
            icon: Icons.receipt_long,
            label: "Quản lý Booking",
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminBookingScreen()),
            ),
          ),
          drawerItem(
            icon: Icons.bar_chart,
            label: "Thống kê doanh thu",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminStatisticsScreen()),
            ),
          ),
          drawerItem(
            icon: Icons.person_add_alt_1,
            label: "Tạo Provider",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminCreateProviderScreen()),
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

  // =========================
  // ⭐ Booking Card (UI đẹp hơn)
  // =========================
  Widget bookingCard(Map booking) {
    bool isPaid = booking['PaymentStatus'] == "Đã thanh toán";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 5,
        shadowColor: Colors.indigo.shade200,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                    isPaid ? Colors.green.shade500 : Colors.red.shade400,
                    child: Icon(
                      isPaid ? Icons.check : Icons.pending,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      booking['TourName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text("👤 Khách hàng: ${booking['CustomerName']}",
                  style: const TextStyle(fontSize: 15)),

              const SizedBox(height: 4),

              Text("🗓 Ngày đặt: ${booking['BookingDate']}",
                  style: TextStyle(color: Colors.grey.shade700)),

              const SizedBox(height: 6),

              Text(
                "💰 Trạng thái: ${booking['PaymentStatus']}",
                style: TextStyle(
                  color: isPaid ? Colors.green.shade600 : Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: isPaid
                      ? null
                      : () async {
                    bool ok = await AdminApiService.confirmBooking(
                        booking['BookingID']);
                    if (ok) load();
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(isPaid ? "Đã thanh toán" : "Xác nhận thanh toán",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPaid ? Colors.green : Colors.white,
                  ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isPaid ? Colors.grey.shade400 : Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // ⭐ Giao diện chính
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Booking"),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      drawer: buildDrawer(),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // ===== Filter UI (Nâng cấp đẹp hơn) =====
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: monthController,
                        decoration: _input("Tháng (YYYY-MM)"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: tourNameController,
                        decoration: _input("Tên tour"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField(
                  value: paymentFilter,
                  decoration: _input("Trạng thái"),
                  items: const [
                    DropdownMenuItem(
                        value: "Tất cả", child: Text("Tất cả")),
                    DropdownMenuItem(
                        value: "Đã thanh toán",
                        child: Text("Đã thanh toán")),
                    DropdownMenuItem(
                        value: "Chưa thanh toán",
                        child: Text("Chưa thanh toán")),
                  ],
                  onChanged: (v) =>
                      setState(() => paymentFilter = v.toString()),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: filter,
                    icon: const Icon(Icons.filter_alt),
                    label: const Text("Lọc kết quả",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              ],
            ),
          ),

          // ===== List =====
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(
              child: Text(
                "Không tìm thấy booking nào!",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredBookings.length,
              itemBuilder: (_, i) => bookingCard(
                filteredBookings[i],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ⭐ Style textfield
  // =========================
  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
