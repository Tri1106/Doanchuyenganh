import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({super.key});

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final tourID = TextEditingController();
  final airline = TextEditingController();
  final depart = TextEditingController();
  final dest = TextEditingController();
  final price = TextEditingController();

  DateTime? departTime;
  DateTime? returnTime;

  Future pickDate(bool isDepart) async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isDepart) {
          departTime = date;
        } else {
          returnTime = date;
        }
      });
    }
  }

  void save() async {
    final data = {
      "tourID": tourID.text,
      "airline": airline.text,
      "departurePoint": depart.text,
      "destinationPoint": dest.text,
      "price": price.text,
      "departTime": departTime!.toIso8601String(),
      "returnTime": returnTime!.toIso8601String(),
    };

    bool ok = await ApiService.addFlight(data);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm vé máy bay thành công!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Vé Máy Bay")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Tour ID", tourID),
            _input("Hãng bay", airline),
            _input("Điểm khởi hành", depart),
            _input("Điểm đến", dest),
            _input("Giá vé", price, type: TextInputType.number),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => pickDate(true),
              child: Text(departTime == null ? "Chọn ngày đi" : departTime.toString()),
            ),
            ElevatedButton(
              onPressed: () => pickDate(false),
              child: Text(returnTime == null ? "Chọn ngày về" : returnTime.toString()),
            ),

            const SizedBox(height: 15),
            ElevatedButton(onPressed: save, child: const Text("Lưu")),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
