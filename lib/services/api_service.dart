import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/tour_model.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // ============================
  // 🔰 AUTH
  // ============================

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/account/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'message': 'Sai tài khoản hoặc mật khẩu'};
    } catch (e) {
      return {'message': 'Không thể kết nối server: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
      String fullname, String email, String phone, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/account/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'message': "Đăng ký thành công!"};
      } else {
        return {
          'success': false,
          'message': jsonDecode(res.body)['message'] ?? "Lỗi không xác định"
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Không thể kết nối server"};
    }
  }

  // ============================
  // 🔰 TOUR PUBLIC
  // ============================

  static Future<List<Tour>> getPopularTours() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/popular-tours'));

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((e) => Tour.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Tour>> getAllTours() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/tours'));

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((e) => Tour.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================
  // 🔰 TOUR CRUD - PROVIDER
  // ============================

  static Future<List<dynamic>> getMyTours() async {
    final url = Uri.parse('$baseUrl/tours');
    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> addTour(Map<String, dynamic> data, File? imageFile) async {
    final url = Uri.parse('$baseUrl/add-tour');

    var req = http.MultipartRequest("POST", url);

    data.forEach((k, v) => req.fields[k] = v.toString());

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath("tourImage", imageFile.path));
    }

    try {
      final res = await req.send();
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateTour(String tourID, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/edit-tour/$tourID');

    try {
      final res = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteTour(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/delete-tour/$id'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================
  // 🔰 HOTEL
  // ============================

  static Future<bool> addHotel(Map<String, String> data, File? image) async {
    final url = Uri.parse('$baseUrl/add-hotel');
    var req = http.MultipartRequest("POST", url);

    data.forEach((key, value) => req.fields[key] = value);

    if (image != null) {
      req.files.add(await http.MultipartFile.fromPath("hotelImage", image.path));
    }

    try {
      final response = await req.send();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================
  // 🔰 FLIGHT
  // ============================

  static Future<bool> addFlight(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/add-flight'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================
  // 🔰 TOUR DETAILS
  // ============================

  static Future<Map<String, dynamic>?> getTourDetails(String tourID) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/tour-details/$tourID'),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}

    return null;
  }

  // ============================
  // 🔰 ITINERARY CRUD
  // ============================

  static Future<List<dynamic>> getItineraries(String tourID) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/itineraries/$tourID'),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}

    return [];
  }

  static Future<bool> addItinerary(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/add-itinerary'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateItinerary(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/edit-itinerary/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteItinerary(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/delete-itinerary/$id'),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
