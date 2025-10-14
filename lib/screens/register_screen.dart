import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    bool success = await ApiService.register(
      fullnameController.text,
      emailController.text,
      phoneController.text,
      passwordController.text,
    );

    setState(() {
      _isLoading = false;
      _message = success
          ? 'Đăng ký thành công! Vui lòng đăng nhập.'
          : 'Đăng ký thất bại.';
    });

    if (success) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: fullnameController, decoration: const InputDecoration(labelText: "Họ và tên")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Số điện thoại")),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu")),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Text(_message, style: TextStyle(color: _message.contains('thành công') ? Colors.green : Colors.red)),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Đăng ký"),
            ),
          ],
        ),
      ),
    );
  }
}
