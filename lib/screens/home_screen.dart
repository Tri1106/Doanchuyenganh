import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../models/tour_model.dart';
import 'tour_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Tour>> _popularTours;
  late Future<List<Tour>> _allTours;

  final _scrollController = ScrollController();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _popularTours = ApiService.getPopularTours();
    _allTours = ApiService.getAllTours();
    _fadeController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Trang chủ", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 4,
        shadowColor: Colors.tealAccent.withOpacity(0.4),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _popularTours = ApiService.getPopularTours();
              _allTours = ApiService.getAllTours();
            });
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 Chào người dùng
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Xin chào, ${user['fullname'] ?? user['username'] ?? 'Người dùng'} 👋",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                ),

                // 🔍 Thanh tìm kiếm
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm tour du lịch...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 🌟 Tour nổi bật
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Tour nổi bật",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: FutureBuilder<List<Tour>>(
                    future: _popularTours,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerList(isHorizontal: true);
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final tours = snapshot.data!;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tours.length,
                          itemBuilder: (context, index) {
                            final tour = tours[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              width: 180,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(2, 3),
                                  )
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        TourDetailScreen(tourId: tour.tourID),
                                  ));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: Image.network(
                                        getFullImageUrl(tour.imageURL),
                                        height: 130,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image,
                                            size: 50),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        tour.tourName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                        formatPrice(tour.price),
                                        style: const TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                            child: Text("Không có tour nổi bật"));
                      }
                    },
                  ),
                ),

                // 📋 Tất cả tour
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Tất cả tour",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                FutureBuilder<List<Tour>>(
                  future: _allTours,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerList();
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
                          final destination =
                          (tour.destination?.isNotEmpty ?? false)
                              ? tour.destination!
                              : 'Chưa có địa điểm';
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 600),
                            opacity: 1,
                            child: Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    getFullImageUrl(tour.imageURL),
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  tour.tourName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(destination),
                                trailing: Text(
                                  formatPrice(tour.price),
                                  style: const TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.w500),
                                ),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        TourDetailScreen(tourId: tour.tourID),
                                  ));
                                },
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text("Không có tour nào"));
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shimmer loading effect
  Widget _buildShimmerList({bool isHorizontal = false}) {
    return ListView.builder(
      scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
      shrinkWrap: !isHorizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: isHorizontal ? 3 : 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.all(8),
            height: isHorizontal ? 200 : 100,
            width: isHorizontal ? 160 : double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
