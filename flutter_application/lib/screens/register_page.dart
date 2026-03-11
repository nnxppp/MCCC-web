import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // === THEME CONFIG ===
  static const Color kPrimaryGreen = Color(0xFF006A4E); // เขียวเข้ม
  static const Color kSoftGreen    = Color(0xFFF4F9F4); // เขียวอ่อน (พื้นหลัง)

  final _formKey = GlobalKey<FormState>();

  // Controllers สำหรับรับค่าจากฟอร์ม
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; 
  bool _obscurePassword = true; 

  // --- ฟังก์ชันลงทะเบียน ---
  Future<void> _sendRegisterRequest() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final uri = Uri.parse('https://mccc-api.onrender.com/register');
      
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (!mounted) return;

      final bodyLower = res.body.toLowerCase();
      
      // เช็คว่าอีเมลซ้ำหรือไม่
      final isDuplicate = res.statusCode == 409 ||
          bodyLower.contains('exist') ||
          bodyLower.contains('duplicate') ||
          bodyLower.contains('already');

      if (isDuplicate) {
        _showAlertDialog('อีเมลมีอยู่แล้ว', 'อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่น');
      } else if (res.statusCode == 200 || res.statusCode == 201) {
        // --- สำเร็จ ---
        await _showAlertDialog(
          'ลงทะเบียนสำเร็จ',
          'คุณสามารถเข้าสู่ระบบได้ทันที',
          isSuccess: true,
        );
        
        if (mounted) {
          Navigator.of(context).pop(); // กลับไปหน้า Login
        }
      } else {
        // --- กรณี Error อื่นๆ ---
        final msg = res.body.isNotEmpty ? res.body : 'ลงทะเบียนไม่สำเร็จ (${res.statusCode})';
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

  // Helper: แสดง SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : kPrimaryGreen, // ใช้สีธีมเมื่อสำเร็จ
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper: แสดง Dialog แจ้งเตือน
  Future<void> _showAlertDialog(String title, String content, {bool isSuccess = false}) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: isSuccess ? kPrimaryGreen : Colors.red)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ตกลง', style: TextStyle(color: kPrimaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftGreen, // 1. พื้นหลังเขียวอ่อน
      appBar: AppBar(
        title: const Text('ลงทะเบียนสมาชิก', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: kPrimaryGreen, // 2. AppBar เขียวเข้ม
        iconTheme: const IconThemeData(color: Colors.white), // ลูกศรย้อนกลับสีขาว
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1, size: 80, color: kPrimaryGreen), // 3. ไอคอนหลัก
                const SizedBox(height: 20),
                const Text(
                  'สร้างบัญชีใหม่',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen // 4. สีหัวข้อ
                  ),
                ),
                const SizedBox(height: 30),

                // --- 1. ช่องกรอกชื่อ ---
                TextFormField(
                  controller: _nameController,
                  cursorColor: kPrimaryGreen,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: kPrimaryGreen), // สีตอนกดพิมพ์
                    prefixIcon: Icon(Icons.person_outline, color: kPrimaryGreen), // ไอคอนเขียว
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryGreen, width: 2), // เส้นขอบตอนพิมพ์
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกชื่อ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- 2. ช่องกรอกอีเมล ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: kPrimaryGreen,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: kPrimaryGreen),
                    prefixIcon: Icon(Icons.email_outlined, color: kPrimaryGreen),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกอีเมล';
                    if (!value.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- 3. ช่องกรอกรหัสผ่าน ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  cursorColor: kPrimaryGreen,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: const TextStyle(color: kPrimaryGreen),
                    prefixIcon: const Icon(Icons.lock_outline, color: kPrimaryGreen),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: kPrimaryGreen, // ตาเขียว
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                    if (value.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // --- ปุ่มลงทะเบียน ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendRegisterRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen, // 5. ปุ่มสีเขียว
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'ลงทะเบียน',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- ปุ่มกลับไป Login ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('มีบัญชีอยู่แล้ว? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // กลับไปหน้า Login
                      },
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          color: kPrimaryGreen, // 6. ลิงก์สีเขียว
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}