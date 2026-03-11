import 'dart:async';
import 'dart:convert';
import 'package:example/screens/home_page.dart';
import 'package:example/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // === THEME CONFIG (ชุดสีเดียวกับหน้า Home) ===
  static const Color kPrimaryGreen = Color(0xFF006A4E);
  static const Color kSoftGreen = Color(0xFFF4F9F4);
  
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('https://mccc-api.onrender.com/login');
      final body = jsonEncode({
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      });

      print('Connecting to: $uri');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final name = data['name'];
        final email = data['email'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_name', name ?? _emailController.text);
          await prefs.setString('user_email', email ?? _emailController.text);
          await prefs.setBool('logged_in', true);

          if (mounted) {
            // === แก้ไขตรงนี้: ส่งคำสั่งเปิด Drawer ไปด้วย ===
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(), // <--- ใส่ true ตรงนี้
              ),
            );
          }
        } else {
          _showErrorDialog('เข้าระบบสำเร็จแต่ไม่ได้รับ Token');
        }
      } else if (response.statusCode == 403) {
        final msg = data['message'] ?? 'บัญชีของคุณยังไม่ได้รับอนุมัติ';
        _showErrorDialog(msg, isWarning: true);
      } else {
        final msg = data['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        _showErrorDialog('$msg (${response.statusCode})');
      }
    } on TimeoutException {
      _showErrorDialog('หมดเวลาเชื่อมต่อ (เซิร์ฟเวอร์อาจกำลังตื่น กรุณาลองใหม่)');
    } catch (e) {
      print('Login Error: $e');
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message, {bool isWarning = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isWarning ? 'แจ้งเตือนสถานะบัญชี' : 'เข้าสู่ระบบไม่สำเร็จ',
            style: const TextStyle(color: kPrimaryGreen)), 
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ตกลง', style: TextStyle(color: kPrimaryGreen)), 
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftGreen, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/mccc.png', 
                        fit: BoxFit.contain,
                        height: 100, 
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'MCCC Login',
                        style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: kPrimaryGreen 
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Email Field ---
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
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

                      // --- Password Field ---
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle: const TextStyle(color: kPrimaryGreen),
                          prefixIcon: const Icon(Icons.lock_outline, color: kPrimaryGreen), 
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: kPrimaryGreen, 
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                          return null;
                        },
                        onFieldSubmitted: (_) => _performLogin(),
                      ),
                      const SizedBox(height: 24),
                      
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                            );
                          },
                          child: const Text('ลืมรหัสผ่าน?',
                              style: TextStyle(color: kPrimaryGreen)), 
                        ),
                      ),

                      const SizedBox(height: 16),
                      // --- Login Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _performLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen, 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('เข้าสู่ระบบ',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ยังไม่มีบัญชี? '),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: const Text('สมัครสมาชิก', 
                              style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)), 
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}