import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

class AdminStatisticsScreen extends StatefulWidget {
  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  List data = [];
  bool loading = false;

  final month = TextEditingController();
  final tour = TextEditingController();

  String payment = "Tất cả";

  Future load() async {
    setState(() => loading = true);

    data = await AdminApiService.getStatistics(
      month: month.text.trim(),
      tourName: tour.text.trim(),
      paymentStatus: payment,
    );

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ----- FILTER FORM -----
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: month,
                decoration:
                const InputDecoration(labelText: "Tháng (YYYY-MM)"),
              ),
              TextField(
                controller: tour,
                decoration: const InputDecoration(labelText: "Tên tour"),
              ),
              DropdownButton(
                value: payment,
                items: const [
                  DropdownMenuItem(value: "Tất cả", child: Text("Tất cả")),
                  DropdownMenuItem(
                      value: "Đã thanh toán", child: Text("Đã thanh toán")),
                  DropdownMenuItem(
                      value: "Chưa thanh toán", child: Text("Chưa thanh toán")),
                ],
                onChanged: (v) => setState(() => payment = v!),
              ),
              ElevatedButton(onPressed: load, child: const Text("Lọc")),
            ],
          ),
        ),

        // ----- RESULT -----
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final r = data[i];
                return Card(
                  child: ListTile(
                    title: Text(r["TourName"]),
                    subtitle: Text(
                        "${r["CustomerName"]} - ${r["PaymentStatus"]}"),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
