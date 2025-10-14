import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiTestPage extends StatefulWidget {
  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String message = "Đang tải...";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
      await http.get(Uri.parse("http://10.0.2.2:3000/home")); // ← API backend Node.js

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          message = data["message"];
        });
      } else {
        setState(() {
          message = "Lỗi: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Không thể kết nối API: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test API Node.js")),
      body: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
