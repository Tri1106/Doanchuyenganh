import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_edit_itinerary_screen.dart';

class ItineraryListScreen extends StatefulWidget {
  final String tourID;
  const ItineraryListScreen({super.key, required this.tourID});

  @override
  State<ItineraryListScreen> createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  List list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    final data = await ApiService.getItineraries(widget.tourID);
    setState(() {
      list = data;
      loading = false;
    });
  }

  void remove(String id) async {
    await ApiService.deleteItinerary(id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lịch trình Tour ${widget.tourID}")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddEditItineraryScreen(
                    tourID: widget.tourID, isEdit: false)),
          ).then((_) => load());
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final item = list[i];
          return ListTile(
            title: Text("Ngày ${item["DayNumber"]}: ${item["Title"]}"),
            subtitle: Text(item["Meals"] ?? ""),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditItineraryScreen(
                          tourID: widget.tourID,
                          isEdit: true,
                          itinerary: item,
                        ),
                      ),
                    ).then((_) => load());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => remove(item["ItineraryID"]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
