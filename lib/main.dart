import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🧑‍💻 Tạo user giả để test HomeScreen
    final mockUser = {
      'fullname': 'Người dùng thử',
      'username': 'demo_user',
      'role': 'customer',
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tour App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(user: mockUser), // ✅ Truyền user giả
    );
  }
}
