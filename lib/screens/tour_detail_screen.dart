import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../services/api_service.dart';
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
      final response = await ApiService.getTourDetails(widget.tourId);

      if (response != null) {
        setState(() {
          tourDetail = response;
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

  String formatPrice(dynamic price) {
    if (price == null) return "Liên hệ";
    final formatter = NumberFormat('#,###', 'vi_VN');
    return "${formatter.format(double.tryParse(price.toString()) ?? 0)} đ";
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

    // 🖼 Banner image
    final bannerPath = tour['ImageURL'] ?? '';
    final imageUrl = bannerPath.startsWith('http')
        ? bannerPath
        : '${ApiService.base}/${bannerPath.replaceFirst(RegExp(r"^/+"), "")}';

    return Scaffold(
      appBar: AppBar(
        title: Text(tour['TourName'] ?? 'Chi tiết tour'),
        backgroundColor: Colors.teal,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(
                tourID: tour['TourID'],
                tourName: tour['TourName'],
                tourPrice: double.tryParse("${tour['Price']}") ?? 0,
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
            // 🖼 Banner
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 230,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 80),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên tour
                  Text(
                    tour['TourName'] ?? "Không có tên",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    "Điểm đến: ${tour['Destination'] ?? 'Không có'}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    formatPrice(tour['Price']),
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold),
                  ),

                  const Divider(height: 30),

                  _infoRow(Icons.directions_bus, "Phương tiện",
                      tour['PhuongTien']),
                  _infoRow(Icons.discount, "Khuyến mãi", tour['KhuyenMai']),
                  _infoRow(Icons.people, "Đối tượng phù hợp",
                      tour['DoiTuongThichHop']),
                  _infoRow(Icons.access_time, "Thời gian lý tưởng",
                      tour['ThoiGianLyTuong']),
                  const SizedBox(height: 20),

                  // 🏨 Khách sạn
                  if (hotels.isNotEmpty) ...[
                    const Text(
                      "Khách sạn",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hotels.length,
                        itemBuilder: (context, i) {
                          final h = hotels[i];
                          final hUrl = (h['ImageURL'] ?? '').startsWith('http')
                              ? h['ImageURL']
                              : '${ApiService.base}/${(h['ImageURL'] ?? "").replaceFirst(RegExp(r"^/+"), "")}';

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
                                      hUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: Colors.grey[200]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(h['HotelName'] ?? '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(h['Location'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        Text(
                                            formatPrice(
                                                h['PricePerNight'] ?? 0),
                                            style: const TextStyle(
                                                color: Colors.teal)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ✈️ Flights
                  if (flights.isNotEmpty) ...[
                    const Text(
                      "Vé máy bay",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    ...flights.map((f) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.flight_takeoff,
                            color: Colors.teal),
                        title: Text(f['Airline'] ?? ''),
                        subtitle: Text(
                            "${f['DeparturePoint']} → ${f['DestinationPoint']}"),
                        trailing: Text(
                          formatPrice(f['Price']),
                          style: const TextStyle(color: Colors.teal),
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // 📅 Itineraries
                  if (itineraries.isNotEmpty) ...[
                    const Text(
                      "Lịch trình",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    ...itineraries.map((it) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            it['DayNumber'].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(it['Title'] ?? ''),
                        subtitle: Text(it['Details'] ?? ''),
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
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
