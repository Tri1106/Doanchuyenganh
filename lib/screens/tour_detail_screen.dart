import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import 'booking_detail_screen.dart';
import 'booking_screen.dart';


class TourDetailScreen extends StatefulWidget {
  final String tourId;
  const TourDetailScreen({Key? key, required this.tourId}) : super(key: key);

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  Map<String, dynamic>? tourDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTourDetail();
  }

  Future<void> fetchTourDetail() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/tours/${widget.tourId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tourDetail = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Không thể tải dữ liệu tour');
      }
    } catch (e) {
      print('❌ Lỗi khi load chi tiết tour: $e');
      setState(() => isLoading = false);
    }
  }

  String formatPrice(double? price) {
    if (price == null) return "Liên hệ";
    final formatter = NumberFormat('#,###', 'vi_VN');
    return "${formatter.format(price)} đ";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tourDetail == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy tour")),
      );
    }

    final tour = tourDetail!['tour'];
    final hotels = tourDetail!['hotels'] ?? [];
    final flights = tourDetail!['flights'] ?? [];
    final itineraries = tourDetail!['itineraries'] ?? [];

    // 🖼 Xử lý ảnh banner
    final bannerPath = tour['ImageURL'] ?? tour['HinhAnh'] ?? '';
    final imageUrl = bannerPath.toString().startsWith('http')
        ? bannerPath
        : '${ApiService.baseUrl}/${bannerPath.replaceFirst(RegExp(r"^/+"), "")}';

    return Scaffold(
      appBar: AppBar(
        title: Text(tour['TenTour']),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(
                tourID: tour['TourID'].toString(),
                tourName: tour['TenTour'] ?? 'Không có tên',
                tourPrice: double.tryParse(tour['Gia'].toString()) ?? 0.0,
                tourImage: imageUrl,
              ),
            ),
          );
        },

        label: const Text("Đặt tour ngay"),
        icon: const Icon(Icons.shopping_cart),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Ảnh banner
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                height: 230,
                width: double.infinity,
                child: const Icon(Icons.image_not_supported, size: 80),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour['TenTour'] ?? 'Không có tên',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Điểm đến: ${tour['Destination'] ?? 'Chưa có'}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(double.tryParse('${tour['Gia']}')),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 30),

                  // 🌐 Thông tin chung
                  _infoRow(Icons.directions_bus, "Phương tiện", tour['PhuongTien']),
                  _infoRow(Icons.discount, "Khuyến mãi", tour['KhuyenMai']),
                  _infoRow(Icons.people, "Đối tượng phù hợp", tour['DoiTuongThichHop']),
                  _infoRow(Icons.access_time, "Thời gian lý tưởng", tour['ThoiGianLyTuong']),
                  const SizedBox(height: 20),

                  // 🏨 Khách sạn
                  if (hotels.isNotEmpty) ...[
                    const Text("Khách sạn",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = hotels[index];
                          final hotelImage = hotel['ImageURL'] ?? '';
                          final hotelImageUrl = hotelImage.toString().startsWith('http')
                              ? hotelImage
                              : '${ApiService.baseUrl}/${hotelImage.replaceFirst(RegExp(r"^/+"), "")}';

                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      hotelImageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.hotel, size: 60),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hotel['HotelName'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          hotel['Location'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                          formatPrice(double.tryParse('${hotel['PricePerNight']}')),
                                          style: const TextStyle(color: Colors.teal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ✈️ Chuyến bay
                  if (flights.isNotEmpty) ...[
                    const Text("Vé máy bay",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...flights.map((flight) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.flight_takeoff, color: Colors.teal),
                        title: Text(flight['Airline'] ?? ''),
                        subtitle: Text(
                            "${flight['DeparturePoint']} → ${flight['DestinationPoint']}"),
                        trailing: Text(
                          formatPrice(double.tryParse('${flight['Price']}')),
                          style: const TextStyle(color: Colors.teal),
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // 📅 Lịch trình
                  if (itineraries.isNotEmpty) ...[
                    const Text("Lịch trình chi tiết",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...itineraries.map((item) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text('${item['day']}',
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(item['Title'] ?? ''),
                        subtitle: Text(item['Details'] ?? ''),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 8),
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
