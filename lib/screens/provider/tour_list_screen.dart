import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'tour_form_screen.dart';
import 'itinerary_list_screen.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  List tours = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTours();
  }

  Future loadTours() async {
    final data = await ApiService.getMyTours();
    setState(() {
      tours = data;
      loading = false;
    });
  }

  void deleteTour(String id) async {
    final ok = await ApiService.deleteTour(id);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Đã xóa tour")));
      loadTours();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Xóa thất bại")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách tour")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TourFormScreen(isEdit: false),
            ),
          ).then((_) => loadTours());
        },
        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: tours.length,
        itemBuilder: (context, i) {
          final t = tours[i];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                t["TourName"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Điểm đến: ${t["Destination"]}"),

              leading: t["ImageURL"] != null
                  ? Image.network(
                "http://10.0.2.2:3000${t["ImageURL"]}",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image, size: 40),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔵 Xem lịch trình
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.indigo),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItineraryListScreen(
                            tourID: t["TourID"],
                          ),
                        ),
                      );
                    },
                  ),

                  /// ✏️ Sửa tour
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TourFormScreen(
                            isEdit: true,
                            tour: t,
                          ),
                        ),
                      ).then((_) => loadTours());
                    },
                  ),

                  /// ❌ Xóa tour
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteTour(t["TourID"]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
