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

      print('📡 [LOGIN] URL: $baseUrl/account/login');
      print('📦 [LOGIN] Status Code: ${response.statusCode}');
      print('📨 [LOGIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('user')) {
          return data;
        }
        return {
          'message': data['message'] ?? 'Đăng nhập thành công!',
          'user': data,
        };
      } else {
        print('❌ [LOGIN] Thất bại: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ [LOGIN] Lỗi khi gọi API: $e');
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

      print('📡 [REGISTER] URL: $baseUrl/account/register');
      print('📦 [REGISTER] Status Code: ${response.statusCode}');
      print('📨 [REGISTER] Body: ${response.body}');

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
      print('⚠️ [REGISTER] Lỗi khi gọi API: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối máy chủ.',
      };
    }
  }

  // 🟩 Lấy tour nổi bật
  static Future<List<Tour>> getPopularTours() async {
    try {
      final url = Uri.parse('$baseUrl/api/popular-tours');
      final response = await http.get(url);

      print('📡 [POPULAR TOURS] Gọi tới: $url');
      print('📦 [POPULAR TOURS] Status Code: ${response.statusCode}');
      print('📨 [POPULAR TOURS] Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Tour.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('⚠️ [POPULAR TOURS] Lỗi: $e');
      return [];
    }
  }

  // 🟩 Lấy tất cả tour
  static Future<List<Tour>> getAllTours() async {
    try {
      final url = Uri.parse('$baseUrl/api/tours');
      final response = await http.get(url);

      print('📡 [ALL TOURS] Gọi tới: $url');
      print('📦 [ALL TOURS] Status Code: ${response.statusCode}');
      print('📨 [ALL TOURS] Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Tour.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('⚠️ [ALL TOURS] Lỗi: $e');
      return [];
    }
  }
}
