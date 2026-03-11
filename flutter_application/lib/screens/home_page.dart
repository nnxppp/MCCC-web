import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import หน้าลูกข่ายให้ครบ
import 'package:example/widgets/MyDrawer.dart';
import 'package:example/screens/sample_list_page.dart';
import 'package:example/screens/scan_qrcode_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // === THEME SETUP ===
  static const Color kPrimaryGreen = Color(0xFF006A4E);
  static const Color kSoftGreen = Color(0xFFF4F9F4);
  static const Color kCardGreen = Color(0xFFE8F3EE);

  String _userName = 'Loading...';
  String _userEmail = '';

  Widget? _currentContent;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _currentContent = null;
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

  // ฟังก์ชันสลับหน้า
  void _switchContent(Widget? page) {
    Widget? newPage = page;

    // เช็คว่าหน้าที่ส่งมาคือหน้าอะไร แล้ว "สร้างใหม่" พร้อมยัด callback ลงไป
    if (page is SampleListPage) {
      newPage = SampleListPage(onPageChange: _switchContent);
    } else if (page is ScanQrcodePage) {
      newPage = ScanQrcodePage(onPageChange: _switchContent);
    }
    
    setState(() {
      _currentContent = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. ถ้ามีหน้าลูก (Search/Scan) ให้แสดงหน้านั้นเต็มจอทันที
    if (_currentContent != null) {
      return _currentContent!;
    }

    // === Responsive Check ===
    // กำหนดจุดตัด (Breakpoint) ที่ 800 พิกเซล (ปรับเปลี่ยนได้ตามความเหมาะสม)
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    // 2. ถ้าเป็นหน้าหลัก
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kSoftGreen,
      
      // แสดง AppBar เฉพาะบนหน้าจอมือถือ (เพื่อโชว์ปุ่ม Hamburger Menu)
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text("หน้าหลัก"),
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
            ),
            
      // สร้าง Drawer แบบเลื่อนซ่อนได้สำหรับมือถือ
      drawer: isDesktop
          ? null
          : Drawer(
              child: MyDrawer(
                userName: _userName,
                userEmail: _userEmail,
                activePage: "Home",
                onMenuTap: (widget) {
                  // ปิด Drawer ก่อนทำการสลับหน้า
                  Navigator.pop(context);
                  _switchContent(widget);
                },
              ),
            ),
            
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ------------------------------------------------------
                // ส่วนซ้าย: Drawer ค้าง (สำหรับ Desktop/Tablet แนวนอน)
                // ------------------------------------------------------
                SizedBox(
                  width: 300,
                  child: MyDrawer(
                    userName: _userName,
                    userEmail: _userEmail,
                    activePage: "Home",
                    onMenuTap: (widget) {
                      _switchContent(widget);
                    },
                  ),
                ),

                // ------------------------------------------------------
                // ส่วนขวา: Dashboard Content
                // ------------------------------------------------------
                Expanded(
                  child: Container(
                    color: kSoftGreen,
                    child: _buildDashboardContent(isDesktop: isDesktop),
                  ),
                ),
              ],
            )
          // ------------------------------------------------------
          // หน้าจอมือถือ: แสดงแค่เนื้อหา Dashboard เต็มจอ (ซ่อนเมนูไว้ใน Drawer แล้ว)
          // ------------------------------------------------------
          : Container(
              color: kSoftGreen,
              child: _buildDashboardContent(isDesktop: isDesktop),
            ),
    );
  }

  // เพิ่ม Parameter isDesktop เข้ามาเพื่อปรับ Layout ด้านในเล็กน้อยหากจำเป็น
  Widget _buildDashboardContent({required bool isDesktop}) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 30.0 : 20.0), // บนจอใหญ่เพิ่ม Padding นิดหน่อย
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Custom Top Bar ---
          // เปลี่ยน Row เป็น Wrap เพื่อป้องกัน Widget Overlap บนจอมือถือที่เล็กมากๆ
         Row(
  crossAxisAlignment: CrossAxisAlignment.start, // สั่งให้ทุกอย่างชิดขอบด้านบน
  children: [
    // 1. ส่วนข้อความซ้ายมือ
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ยินดีต้อนรับ", style: TextStyle(fontSize: 18, color: Colors.grey)),
          Text(
            _userName,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kPrimaryGreen),
          ),
        ],
      ),
    ),
    
    // 2. ส่วนไอคอน (จะถูก Expanded ดันมาอยู่ขวาสุด)
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.search, size: 28),
          color: Colors.black87,
          tooltip: 'ค้นหา',
          onPressed: () => _switchContent(
            SampleListPage(onPageChange: _switchContent),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, size: 28),
          color: Colors.black87,
          tooltip: 'สแกนคิวอาร์โค้ด',
          onPressed: () => _switchContent(
            ScanQrcodePage(onPageChange: _switchContent),
          ),
        ),
      ],
    ),
  ],
),

          const SizedBox(height: 20),
          const Divider(), 
          const SizedBox(height: 20),

          // --- Body Content (รายละเอียดระบบ) ---
          const Text(
            "เกี่ยวกับระบบ",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          const Expanded(
            child: SingleChildScrollView(
              child: Text(
                "ยินดีต้อนรับสู่ระบบจัดการคลังจุลินทรีย์ (MCCC)\n\n"
                "แพลตฟอร์มนี้ถูกออกแบบมาเพื่อเป็นศูนย์กลางในการจัดเก็บ และจัดการข้อมูลตัวอย่างทางจุลชีววิทยา รองรับการเพิ่ม แก้ไข และจัดเก็บข้อมูลจากห้องปฏิบัติการ\n\n"
                "คุณสามารถใช้เครื่องมือที่มุมขวาบนเพื่อค้นหาข้อมูลในระบบได้อย่างรวดเร็ว หรือเลือกสแกนคิวอาร์โค้ด (QR Code) เพื่อเข้าถึงรายละเอียดของตัวอย่างจุลินทรีย์แต่ละชนิดได้ทันที",
                style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveButton({
    required IconData icon,
    required String title,
    required double maxHeight,
    required VoidCallback onTap,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: kCardGreen,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kPrimaryGreen.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: Icon(icon, size: 40, color: kPrimaryGreen),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}