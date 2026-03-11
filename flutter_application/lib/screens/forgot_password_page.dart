import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // --- ฟังก์ชันส่งคำขอรีเซ็ต (ปรับปรุงจากโค้ดของคุณ) ---
  Future<void> _sendResetRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // ปิดคีย์บอร์ด
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();

    try {
      final uri = Uri.parse('https://mccc-api.onrender.com/forgot-password');
      
      print('Sending reset request to: $uri');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        // ✅ สำเร็จ
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('ส่งคำขอสำเร็จ', style: TextStyle(color: Colors.green)),
            content: const Text('กรุณาตรวจสอบอีเมลของคุณเพื่อตั้งรหัสผ่านใหม่'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // ปิด Dialog
                  Navigator.of(context).pop(); // กลับไปหน้า Login
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        // ❌ ไม่สำเร็จ (เช่น อีเมลไม่มีในระบบ)
        final data = jsonDecode(res.body);
        final msg = data['message'] ?? 'ส่งคำขอไม่สำเร็จ (${res.statusCode})';
        _showSnackBar(msg, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลืมรหัสผ่าน'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset, size: 80, color: Colors.teal),
                  const SizedBox(height: 20),
                  const Text(
                    'รีเซ็ตรหัสผ่าน',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'กรุณากรอกอีเมลที่ใช้ลงทะเบียน ระบบจะส่งลิงก์สำหรับตั้งรหัสผ่านใหม่ไปให้',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // --- ช่องกรอกอีเมล ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'กรุณากรอกอีเมล';
                      if (!value.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- ปุ่มส่งคำขอ ---
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'ส่งคำขอรีเซ็ตรหัสผ่าน',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}