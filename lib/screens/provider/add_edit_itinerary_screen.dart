import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddEditItineraryScreen extends StatefulWidget {
  final String tourID;
  final bool isEdit;
  final Map? itinerary;

  const AddEditItineraryScreen({
    super.key,
    required this.tourID,
    required this.isEdit,
    this.itinerary,
  });

  @override
  State<AddEditItineraryScreen> createState() => _AddEditItineraryScreenState();
}

class _AddEditItineraryScreenState extends State<AddEditItineraryScreen> {
  final dayNumber = TextEditingController();
  final title = TextEditingController();
  final meals = TextEditingController();
  final details = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.itinerary != null) {
      dayNumber.text = widget.itinerary!["DayNumber"].toString();
      title.text = widget.itinerary!["Title"];
      meals.text = widget.itinerary!["Meals"] ?? "";
      details.text = widget.itinerary!["Details"] ?? "";
    }
  }

  void save() async {
    final data = {
      "tourID": widget.tourID,
      "dayNumber": int.parse(dayNumber.text),
      "title": title.text,
      "meals": meals.text,
      "details": details.text,
    };

    bool ok;

    if (widget.isEdit) {
      ok = await ApiService.updateItinerary(
          widget.itinerary!["ItineraryID"], data);
    } else {
      ok = await ApiService.addItinerary(data);
    }


    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lưu thành công!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? "Sửa lịch trình" : "Thêm lịch trình"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Ngày thứ", dayNumber),
            _input("Tiêu đề", title),
            _input("Bữa ăn", meals),
            _input("Chi tiết", details, maxLines: 4),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text("Lưu"))
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
