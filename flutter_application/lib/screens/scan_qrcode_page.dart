import 'dart:convert';
import 'dart:io'; 
import 'dart:typed_data';
import 'package:example/screens/mainShow.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

// สำหรับอ่าน QR บน Web/Desktop
import 'package:image/image.dart' as img;
import 'package:zxing_lib/common.dart' as zxing;
import 'package:zxing_lib/qrcode.dart' as zxing;
import 'package:zxing_lib/zxing.dart' as zxing;

// Widgets ของคุณ
import 'package:example/widgets/MyDrawer.dart';

class ScanQrcodePage extends StatefulWidget {
  // 1. เพิ่มตัวแปรรับค่า Callback
  final Function(Widget?)? onPageChange;

  // 2. เพิ่มใน Constructor
  const ScanQrcodePage({
    super.key, 
    this.onPageChange, // <--- ใส่ตรงนี้
  });

  @override
  State<ScanQrcodePage> createState() => _ScanQrcodePageState();
}

class _ScanQrcodePageState extends State<ScanQrcodePage> with WidgetsBindingObserver {
  // ตั้งค่า controller แบบยังไม่เปิดทันที (autoStart: false) เพื่อป้องกัน Error ตอนโหลดหน้าจอ
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
    autoStart: false,
  );
  static const Color kPrimaryGreen = Color(0xFF006A4E);

  String? scannedCode;
  String _userName = 'Loading...';
  String _userEmail = '';
  bool _isFetching = false;
  bool _isCameraRunning = false;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserProfile();
    
    // เรียกใช้หลังจากหน้าจอแรก render เสร็จแล้วเท่านั้น เพื่อเลี่ยง Controller Error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCameraIfNeeded();
    });
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Guest';
        _userEmail = prefs.getString('user_email') ?? '';
      });
    }
  }

  Future<void> _startCameraIfNeeded() async {
    if (!_isCameraRunning && mounted) {
      try {
        await controller.start();
        if (mounted) setState(() => _isCameraRunning = true);
      } catch (e) {
        debugPrint('Camera start error: $e');
      }
    }
  }

  Future<void> _stopCameraIfNeeded() async {
    if (_isCameraRunning) {
      try {
        await controller.stop();
        if (mounted) setState(() => _isCameraRunning = false);
      } catch (e) {
        debugPrint('Camera stop error: $e');
      }
    }
  }

  // จัดการ LifeCycle ของแอป (กันบั๊กกล้องค้างตอนสลับแอป)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startCameraIfNeeded();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopCameraIfNeeded();
    }
  }

  // --- Fetch API และ Navigate ---
  Future<void> _fetchAndNavigate(String scannedValue) async {
    if (_isFetching) return;

    final cleanName = scannedValue.trim();
    _isFetching = true;
    scannedCode = cleanName;
    
    if (mounted) setState(() => _showLoading = true);

    await _stopCameraIfNeeded();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        _handleError('ไม่พบ Token กรุณา Login ใหม่');
        return;
      }

      final url = Uri.parse('https://mccc-api.onrender.com/samples/name/${Uri.encodeComponent(cleanName)}');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String sampleDisplay = cleanName;

        if (data is List && data.isNotEmpty) {
          final first = data[0];
          sampleDisplay = first['sampName'] ?? first['name'] ?? first['desc_samp'] ?? first['organism'] ?? cleanName;
        } else if (data is Map) {
          sampleDisplay = data['sampName'] ?? data['name'] ?? data['desc_samp'] ?? data['organism'] ?? cleanName;
        }

        setState(() => _showLoading = false);

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MainShowPage(sampName: sampleDisplay)),
        );
      } else {
        _handleError('เกิดข้อผิดพลาด: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('เกิดข้อผิดพลาด: $e');
    } finally {
      _isFetching = false;
      scannedCode = null;
      await _startCameraIfNeeded();
      if (mounted) setState(() {});
    }
  }

  void _handleError(String message) {
    if (mounted) setState(() => _showLoading = false);
    _showErrorAndRestartCamera(message);
  }

  void _showErrorAndRestartCamera(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('แจ้งเตือน'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _startCameraIfNeeded();
            },
            child: const Text('ตกลง'),
          )
        ],
      ),
    );
  }

  // --- เลือกรูปจาก Gallery (แก้บั๊ก Cancel แล้วเด้ง) ---
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      // กรณีผู้ใช้ยกเลิก (Cancel)
      if (image == null) {
        await _startCameraIfNeeded(); // ต้องรันกล้องกลับมาทันที
        return;
      }

      await _stopCameraIfNeeded();
      if (mounted) setState(() => _showLoading = true);

      String? result;
      if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        result = await _analyzeImageOnWeb(image);
      } else {
        final capture = await controller.analyzeImage(image.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          result = capture.barcodes.first.rawValue;
        }
      }

      if (mounted) setState(() => _showLoading = false);

      if (result != null && result.isNotEmpty) {
        await _fetchAndNavigate(result);
      } else {
        _showErrorAndRestartCamera('ไม่พบ QR Code ในรูปภาพนี้');
      }
    } catch (e) {
      if (mounted) setState(() => _showLoading = false);
      _showErrorAndRestartCamera('เกิดข้อผิดพลาด: $e');
    } finally {
      await _startCameraIfNeeded();
      if (mounted) setState(() {});
    }
  }

  // --- Decode QR บน Web/Desktop ---
  Future<String?> _analyzeImageOnWeb(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;
      final resized = (image.width > 800 || image.height > 800) ? img.copyResize(image, width: 800) : image;
      final grayImage = img.grayscale(resized);
      final luminances = Int32List(grayImage.width * grayImage.height);
      for (int y = 0; y < grayImage.height; y++) {
        for (int x = 0; x < grayImage.width; x++) {
          final pixel = grayImage.getPixel(x, y);
          luminances[y * grayImage.width + x] = pixel.r.toInt();
        }
      }
      final luminanceSource = zxing.RGBLuminanceSource(grayImage.width, grayImage.height, luminances);
      final binaryBitmap = zxing.BinaryBitmap(zxing.HybridBinarizer(luminanceSource));
      final result = zxing.QRCodeReader().decode(binaryBitmap);
      return result.text;
    } catch (e) {
      return null;
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web QR Scanner'), // หรือเปลี่ยนเป็น 'สแกน QR Code'
        backgroundColor: kPrimaryGreen, // <--- ใส่สีพื้นหลังเขียว
        foregroundColor: Colors.white,  // <--- ใส่สีตัวหนังสือ/ไอคอนเป็นสีขาว
      ),
      drawer: MyDrawer(
        userName: _userName,
        userEmail: _userEmail,
        activePage: "Scan",
        // เพิ่มบรรทัดนี้ครับ 👇
        onMenuTap: (targetWidget) {
          // 1. ปิด Drawer ของหน้านี้ก่อน (เพราะมันเด้งมาทับหน้าจอ)
          Navigator.pop(context); 

          // 2. ถ้ามีฟังก์ชันส่งค่ากลับ (callback) ให้เรียกใช้มัน
          if (widget.onPageChange != null) {
            widget.onPageChange!(targetWidget);
          }
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // --- ส่วนกล้อง (แก้ไขตรงนี้) ---
              Expanded(
                flex: 3,
                child: Center( // 1. ใช้ Center เพื่อไม่ให้ยืดเต็มจอ
                  child: AspectRatio( // 2. บังคับเป็นสี่เหลี่ยมจัตุรัส (1:1)
                    aspectRatio: 1.0, 
                    child: Container(
                      margin: const EdgeInsets.all(50), // 3. เพิ่ม Margin เพื่อให้กรอบเล็กลง/แคบลง (ปรับตัวเลขนี้ได้)
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 4),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _isCameraRunning
                            ? MobileScanner(
                                controller: controller,
                                // กำหนด scanWindow ให้ตรงกับขนาด Widget (Optional: ช่วยให้โฟกัสแม่นขึ้น)
                                scanWindow: Rect.fromCenter(
                                  center: Offset.zero,
                                  width: 200, 
                                  height: 200,
                                ),
                                onDetect: (capture) {
                                  if (_isFetching) return;
                                  for (final barcode in capture.barcodes) {
                                    if (barcode.rawValue != null) {
                                      _fetchAndNavigate(barcode.rawValue!);
                                      break;
                                    }
                                  }
                                },
                              )
                            : const Center(
                                child: Text("กำลังเตรียมกล้อง...",
                                    style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                ),
              ),
              
              // --- ส่วนแสดงผลลัพธ์ (เหมือนเดิม) ---
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.grey[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ผลลัพธ์:', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(
                        scannedCode ?? '...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scannedCode != null ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.image),
                        label: const Text('เลือกรูป QR Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Overlay Loading (เหมือนเดิม) ---
          if (_showLoading)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'กำลังโหลด...',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'กรุณารอสักครู่',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }
}