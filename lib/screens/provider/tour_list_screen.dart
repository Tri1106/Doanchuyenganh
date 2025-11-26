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
  bool sessionExpired = false;

  @override
  void initState() {
    super.initState();
    loadTours();
  }

  Future loadTours() async {
    final data = await ApiService.getMyTours();

    // 🔥 xử lý khi API trả lỗi 400: "Chưa đăng nhập"
    if (data.isEmpty) {
      setState(() {
        loading = false;
        sessionExpired = true;
      });
      return;
    }

    // 🔥 nếu backend trả lỗi ở dạng {"error": "..."}
    if (data is List && data.isNotEmpty && data[0] is Map && data[0]["error"] != null) {
      setState(() {
        loading = false;
        sessionExpired = true;
      });
      return;
    }

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
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ⭐ Khi hết session (cookie hết hạn hoặc API trả 400)
    if (sessionExpired) {
      return Scaffold(
        appBar: AppBar(title: const Text("Danh sách tour")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Phiên đăng nhập đã hết hạn.\nVui lòng đăng nhập lại!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: const Text("Đăng nhập lại"),
              ),
            ],
          ),
        ),
      );
    }

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

      body: ListView.builder(
        itemCount: tours.length,
        itemBuilder: (context, i) {
          final t = tours[i];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                t["TourName"] ?? "Không có tên",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Điểm đến: ${t["Destination"]}"),

              leading: t["ImageURL"] != null
                  ? Image.network(
                "${ApiService.base}${t["ImageURL"]}",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image, size: 40),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.indigo),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ItineraryListScreen(tourID: t["TourID"]),
                        ),
                      );
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TourFormScreen(isEdit: true, tour: t),
                        ),
                      ).then((_) => loadTours());
                    },
                  ),

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
