import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tour_model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

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

  String formatPrice(double? price) {
    if (price == null || price <= 0) return "Liên hệ";
    final formatter = NumberFormat('#,###', 'vi_VN');
    return "${formatter.format(price)} đ";
  }

  String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiService.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

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
                        final tour = tours[index];
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
                                // TODO: Chuyển đến chi tiết tour
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      getFullImageUrl(tour.imageURL),
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.image_not_supported, size: 50),
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
                                      formatPrice(tour.price),
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
                      final tour = tours[index];
                      final destination = (tour.destination?.isNotEmpty ?? false)
                          ? tour.destination!
                          : 'Chưa có địa điểm';
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              getFullImageUrl(tour.imageURL),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image, size: 40),
                            ),
                          ),
                          title: Text(
                            tour.tourName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(destination),
                          trailing: Text(
                            formatPrice(tour.price),
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
