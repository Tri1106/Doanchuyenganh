import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tour_model.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // 🟩 Đăng nhập
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/account/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // ✅ Nếu backend trả {"user": {...}} thì giữ nguyên
        if (data.containsKey('user')) {
          return data;
        }

        // ✅ Nếu backend trả object user trực tiếp thì gói lại để Flutter hiểu
        return {
          'message': data['message'] ?? 'Đăng nhập thành công!',
          'user': data,
        };
      } else {
        print('❌ Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Lỗi khi gọi API login: $e');
      return null;
    }
  }

  // 🟩 Đăng ký
  static Future<Map<String, dynamic>> register(
      String fullname, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/account/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Đăng ký thành công!',
        };
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại.',
        };
      }
    } catch (e) {
      print('⚠️ Lỗi khi gọi API register: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối máy chủ.',
      };
    }
  }

  // 🟩 Lấy tour nổi bật
  static Future<List<Tour>> getPopularTours() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/popular-tours'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Tour.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('getPopularTours error: $e');
      return [];
    }
  }

  static Future<List<Tour>> getAllTours() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/tours'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Tour.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('getAllTours error: $e');
      return [];
    }
  }
}
