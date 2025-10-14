import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000"; // dùng cho emulator Android

  // Đăng nhập
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/account/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Lỗi khi gọi API login: $e');
      return null;
    }
  }

  // Đăng ký
  static Future<bool> register(String fullname, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/account/register'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'fullname': fullname,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      return response.statusCode == 302 || response.statusCode == 200;
    } catch (e) {
      print('⚠️ Lỗi khi gọi API register: $e');
      return false;
    }
  }
}
