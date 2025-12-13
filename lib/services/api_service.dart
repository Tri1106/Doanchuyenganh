import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  static Future<Map<String, dynamic>> login(String username,
      String password) async {
    final url = Uri.parse('$base/account/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📡 STATUS: ${response.statusCode}");
        print("📨 BODY: $data");


        // Lưu cookie nếu có
        if (response.headers['set-cookie'] != null) {
          Session.cookie = response.headers['set-cookie']!.split(';')[0];
          print("🔥 COOKIE LƯU: ${Session.cookie}");
        }

        // Lưu thông tin user vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userID', data['id'] ?? '');
        await prefs.setString('fullname', data['fullname'] ?? '');
        await prefs.setString('role', data['role'] ?? '');

        print("🔥 LƯU USER ID: ${data['id']}");

        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Sai tài khoản hoặc mật khẩu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối server: $e'};
    }
  }


  static Future<Map<String, dynamic>> register(String fullname, String email,
      String phone, String password) async {
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
      print("📡 STATUS: ${res.statusCode}");
      print("📨 BODY: ${res.body}");
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
  static Future<bool> addTour(Map<String, dynamic> data,
      File? imageFile) async {
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

  // UPDATE TOUR
  static Future<bool> updateTour(String tourID,
      Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("$base/provider/edit-tour/$tourID");
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Lỗi updateTour: $e");
      return false;
    }
  }

  static Future<String?> uploadTourImage(String tourID, File image) async {
    try {
      final url = Uri.parse("$base/provider/upload-tour-image/$tourID");
      final request = http.MultipartRequest('POST', url);

      // Thêm file ảnh
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // Nếu backend cần header Authorization hoặc cookie
      // request.headers['Authorization'] = "Bearer your_token";

      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final jsonData = jsonDecode(resBody);
        // Giả sử backend trả JSON { "imageUrl": "uploads/xxxx.jpg" }
        return jsonData["imageUrl"];
      } else {
        print("🔥 Upload ảnh thất bại, status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🔥 Lỗi uploadTourImage: $e");
      return null;
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
      req.files.add(
          await http.MultipartFile.fromPath("hotelImage", image.path));
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

  static Future<bool> updateItinerary(String id,
      Map<String, dynamic> data) async {
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

  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    final url = Uri.parse("$base/user/bookings");

    final headers = <String, String>{};
    if (Session.cookie.isNotEmpty) {
      headers['Cookie'] = Session.cookie;
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = response.body.isNotEmpty ? response.body : "[]";
        final list = List<Map<String, dynamic>>.from(jsonDecode(body));
        return list;
      } else {
        print("⚠️ Lỗi API getUserBookings: ${response.statusCode} ${response
            .body}");
        return [];
      }
    } catch (e) {
      print("🔥 Lỗi khi gọi getUserBookings: $e");
      return [];
    }
  }

// Hủy đơn booking
  static Future<bool> cancelBooking(String bookingID) async {
    final url = Uri.parse("$base/user/bookings/$bookingID/cancel");

    final headers = <String, String>{};
    if (Session.cookie.isNotEmpty) {
      headers['Cookie'] = Session.cookie;
    }

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return data['success'] == true;
      } else {
        print("⚠️ Lỗi API cancelBooking: ${response.statusCode} ${response
            .body}");
        return false;
      }
    } catch (e) {
      print("🔥 Lỗi khi gọi cancelBooking: $e");
      return false;
    }
  }
}
