import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

class AdminTourScreen extends StatefulWidget {
  @override
  State<AdminTourScreen> createState() => _AdminTourScreenState();
}

class _AdminTourScreenState extends State<AdminTourScreen> {
  List tours = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    tours = await AdminApiService.getTours();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
        itemCount: tours.length,
        itemBuilder: (context, i) {
          final t = tours[i];
          return Card(
            child: ListTile(
              title: Text(t["TourName"]),
              subtitle: Text("Giá: ${t["Price"]}"),
              trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool ok = await AdminApiService.deleteTour(t["TourName"]);
                    if (ok) load();
                  }),
            ),
          );
        });
  }
}
