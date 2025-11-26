import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/tour_model.dart';

class Session {
  static String cookie = "";
}

class ApiService {
  // Gốc API
  static const String base = "http://10.0.2.2:3000";

  // ============================
  // 🔰 AUTH
  // ============================

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$base/account/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        if (response.headers['set-cookie'] != null) {
          Session.cookie = response.headers['set-cookie']!.split(';')[0];
          print("🔥 COOKIE LƯU: ${Session.cookie}");
        }

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
        Uri.parse('$base/account/register'),
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
      final response = await http.get(Uri.parse('$base/api/popular-tours'));

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
      final response = await http.get(Uri.parse('$base/api/tours'));

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
  // 🔰 PROVIDER – CRUD TOUR
  // ============================

  /// GET tất cả tour của provider hiện tại
  static Future<List<dynamic>> getMyTours() async {
    final url = Uri.parse('$base/provider/tours');

    try {
      final res = await http.get(
        url,
        headers: {
          "Cookie": Session.cookie,
        },
      );

      print("📡 GET /provider/tours - Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("🔥 DATA: $data");
        return data;
      }

      print("❌ Backend trả về mã ${res.statusCode}");
      print("❌ Body: ${res.body}");
      return [];
    } catch (e) {
      print("❌ Lỗi khi gọi /provider/tours: $e");
      return [];
    }
  }

  // ADD TOUR — multipart
  static Future<bool> addTour(Map<String, dynamic> data, File? imageFile) async {
    final url = Uri.parse('$base/provider/add-tour');
    var req = http.MultipartRequest("POST", url);

    // Cookie session
    if (Session.cookie.isNotEmpty) {
      req.headers["Cookie"] = Session.cookie;
      print("📌 Gửi Cookie: ${req.headers["Cookie"]}");
    }

    // Fields
    data.forEach((key, value) {
      req.fields[key] = value.toString();
    });

    // Ảnh
    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath(
        "tourImage",
        imageFile.path,
      ));
    }

    try {
      final res = await req.send();
      final body = await res.stream.bytesToString();

      print("📡 STATUS: ${res.statusCode}");
      print("📨 BODY: $body");

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (err) {
      print("❌ LỖI ADD TOUR: $err");
      return false;
    }
  }

  // UPDATE TOUR (không ảnh)
  static Future<bool> updateTour(String tourID, Map<String, dynamic> data) async {
    final url = Uri.parse('$base/provider/edit-tour/$tourID');

    try {
      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Cookie": Session.cookie,
        },
        body: jsonEncode(data),
      );

      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // DELETE TOUR
  static Future<bool> deleteTour(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$base/provider/delete-tour/$id'),
        headers: {"Cookie": Session.cookie},
      );

      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================
  // 🔰 HOTEL
  // ============================

  static Future<bool> addHotel(Map<String, String> data, File? image) async {
    final url = Uri.parse('$base/provider/add-hotel');
    var req = http.MultipartRequest("POST", url);

    if (Session.cookie.isNotEmpty) {
      req.headers["Cookie"] = Session.cookie;
    }

    data.forEach((key, value) => req.fields[key] = value);

    if (image != null) {
      req.files.add(await http.MultipartFile.fromPath("hotelImage", image.path));
    }

    try {
      final response = await req.send();
      return response.statusCode == 200 || response.statusCode == 201;
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
        Uri.parse('$base/provider/add-flight'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return res.statusCode == 200 || res.statusCode == 201;
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
        Uri.parse('$base/provider/tour-details/$tourID'),
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
        Uri.parse('$base/provider/itineraries/$tourID'),
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
        Uri.parse('$base/provider/add-itinerary'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateItinerary(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse('$base/provider/edit-itinerary/$id'),
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
        Uri.parse('$base/provider/delete-itinerary/$id'),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
