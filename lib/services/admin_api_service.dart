import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // -------------------------
  // GET Admin Bookings List
  // -------------------------
  static Future<List<dynamic>> getBookings() async {
    final url = Uri.parse("$baseUrl/admin/bookings");
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // -------------------------
  // CONFIRM PAYMENT
  // -------------------------
  static Future<bool> confirmBooking(String id) async {
    final url = Uri.parse("$baseUrl/admin/bookings/$id/confirm");
    try {
      final res = await http.post(url);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // -------------------------
  // GET ALL USERS
  // -------------------------
  static Future<List> getUsers() async {
    final url = Uri.parse("$baseUrl/user/data");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // UPDATE USER
  static Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/user/$id");
    final res = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  // DELETE USER
  static Future<bool> deleteUser(String id) async {
    final url = Uri.parse("$baseUrl/user/$id");
    final res = await http.delete(url);
    return res.statusCode == 200;
  }

  // -------------------------
  // TOURS (Admin)
  // -------------------------
  static Future<List> getTours() async {
    final res = await http.get(Uri.parse("$baseUrl/tours/data"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<bool> updateTour(String id, Map data) async {
    final res = await http.put(
      Uri.parse("$baseUrl/tours/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteTour(String name) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/tours/$name"),
    );
    return res.statusCode == 200;
  }

  // -------------------------
  // BOOKING STATISTICS
  // -------------------------
  static Future<List> getStatistics({
    String? month,
    String? tourName,
    String? paymentStatus,
  }) async {
    final url = Uri.parse(
        "$baseUrl/api/admin/bookings-summary?month=${month ?? ''}&tourName=${tourName ?? ''}&paymentStatus=${paymentStatus ?? ''}");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }
}
