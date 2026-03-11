import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import หน้าเนื้อหาที่จะแสดง
import 'package:example/screens/sample_list_page.dart';
import 'package:example/screens/scan_qrcode_page.dart';
import 'package:example/screens/login_page.dart';

class MyDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String activePage;
  
  // ตัวแปร callback function เพื่อส่ง Widget กลับไปบอก HomePage
  final Function(Widget?)? onMenuTap; 

  const MyDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.activePage,
    this.onMenuTap, 
  });

  // === THEME CONFIG ===
  static const Color kPrimaryGreen = Color(0xFF006A4E);
  static const Color kSoftGreen = Color(0xFFF4F9F4);
  static const Color kCardGreen = Color(0xFFE8F3EE);

  // --- ฟังก์ชันนำทาง ---
  void _navigate(String pageName, Widget? targetWidget) {
    // ส่งค่ากลับไปที่ HomePage ทันที (ไม่ต้องเช็ค activePage เพื่อกันปุ่มค้าง)
    if (onMenuTap != null) {
      onMenuTap!(targetWidget); 
    } 
  }

  // --- Logout ---
  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. ใช้ SizedBox เพื่อล็อคความกว้าง ไม่ให้ Drawer เต็มจอ
    return SizedBox(
      width: 300, // กำหนดความกว้างมาตรฐาน (ปรับเลขนี้ได้ถ้าอยากได้กว้าง/แคบ)
      
      // 2. สำคัญมาก! ต้องหุ้มด้วย Material เพื่อให้ปุ่มกดได้ (รับ Touch Event)
      child: Material(
        color: kSoftGreen, // ใส่สีพื้นหลังตรงนี้
        child: Column(
          children: [
            // ===== Header =====
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: kPrimaryGreen,
              ),
              accountName: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: kPrimaryGreen, size: 40),
              ),
            ),

            // ===== Home =====
            _buildMenuItem(
              context,
              icon: Icons.home,
              title: 'Home',
              isActive: activePage == 'Home',
              onTap: () => _navigate('Home', null), 
            ),

            // ===== Search =====
            _buildMenuItem(
              context,
              icon: Icons.search,
              title: 'Search',
              isActive: activePage == 'Search',
              onTap: () => _navigate('Search', const SampleListPage()),
            ),

            // ===== Scan =====
            _buildMenuItem(
              context,
              icon: Icons.qr_code_scanner,
              title: 'Scan QR Code',
              isActive: activePage == 'Scan',
              onTap: () => _navigate('Scan', const ScanQrcodePage()),
            ),

            const Spacer(),
            const Divider(color: Colors.grey), 

            // ===== Logout =====
            ListTile(
              leading: const Icon(Icons.logout, color: kPrimaryGreen),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: kPrimaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _handleLogout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? kCardGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? kPrimaryGreen : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? kPrimaryGreen : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}