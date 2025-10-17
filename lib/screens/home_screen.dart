import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tour_model.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user; // ✅ Nhận thông tin người dùng từ màn đăng nhập

  const HomeScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Tour>> _popularTours;
  late Future<List<Tour>> _allTours;

  @override
  void initState() {
    super.initState();
    _popularTours = ApiService.getPopularTours();
    _allTours = ApiService.getAllTours();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user; // ✅ Dễ gọi trong UI

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      // 🔹 Thân trang
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 Chào người dùng
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Xin chào, ${user['fullname'] ?? user['username'] ?? 'Người dùng'} 👋",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 🔍 Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Tìm kiếm tour du lịch...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🌟 Tour nổi bật
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Tour nổi bật",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 230,
              child: FutureBuilder<List<Tour>>(
                future: _popularTours,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final tours = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tours.length,
                      itemBuilder: (context, index) {
                        final Tour tour = tours[index];
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.all(8),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                // TODO: Chuyển đến trang chi tiết tour
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      tour.imageURL ?? '', // ✅ tránh null
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      tour.tourName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "${tour.price.toStringAsFixed(0)} VND",
                                      style: const TextStyle(color: Colors.teal),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("Không có tour nổi bật"));
                  }
                },
              ),
            ),

            // 📋 Tất cả tour
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Tất cả tour",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<Tour>>(
              future: _allTours,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final tours = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tours.length,
                    itemBuilder: (context, index) {
                      final Tour tour = tours[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              tour.imageURL ?? '', // ✅ fix null
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image),
                            ),
                          ),
                          title: Text(
                            tour.tourName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(tour.destination ?? ''), // ✅ fix null
                          trailing: Text(
                            "${tour.price.toStringAsFixed(0)}đ",
                            style: const TextStyle(color: Colors.teal),
                          ),
                          onTap: () {
                            // TODO: Chuyển đến chi tiết tour
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("Không có tour nào"));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
