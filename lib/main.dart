import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

import 'services/api_service.dart';   // 🔥 nhớ import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Gọi API để xem key backend
  final tours = await ApiService.getMyTours();
  print("🔥 DATA FROM /tours:");
  print(tours);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tour App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),

      initialRoute: '/login',  // route khởi động

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => HomeScreen(user: {}),
      },
    );
  }
}
