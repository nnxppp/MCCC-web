import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCCC New Sample',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100], // สีพื้นหลังของช่องกรอกข้อมูล
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // ไม่มีเส้นขอบ
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.green, width: 1.0), // เส้นขอบสีเขียวเมื่อ Focus
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green, // สีข้อความและพื้นหลัง
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green, // สีข้อความ
            side: const BorderSide(color: Colors.green, width: 1), // สีเส้นขอบ
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const NewSampleScreen(),
    );
  }
}

class NewSampleScreen extends StatefulWidget {
  const NewSampleScreen({super.key});

  @override
  State<NewSampleScreen> createState() => _NewSampleScreenState();
}

class _NewSampleScreenState extends State<NewSampleScreen> {
  // --- ตัวแปรสำหรับเก็บข้อมูลและควบคุม Widget ---
  final TextEditingController _sampleTitleController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController(text: '7.563, 100.5018');
  final TextEditingController _placeNameController = TextEditingController(text: 'Bang Nam Chuet, Samut Sakhon');
  final TextEditingController _collectionDateController = TextEditingController(text: '2023-10-27');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _organismController = TextEditingController();
  final TextEditingController _environmentMediumController = TextEditingController();
  final TextEditingController _collectionMethodController = TextEditingController();

  // ตัวอย่างรูปภาพ (สามารถเปลี่ยนเป็น List<File> หรือ List<String> สำหรับ URL ได้)
  final List<String> _images = [
    'https://via.placeholder.com/100x100/A0522D/FFFFFF?text=Soil+1',
    'https://via.placeholder.com/100x100/A0522D/FFFFFF?text=Soil+2',
    'https://via.placeholder.com/100x100/A0522D/FFFFFF?text=Soil+3',
  ];
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _sampleTitleController.dispose();
    _gpsController.dispose();
    _placeNameController.dispose();
    _collectionDateController.dispose();
    _descriptionController.dispose();
    _organismController.dispose();
    _environmentMediumController.dispose();
    _collectionMethodController.dispose();
    super.dispose();
  }

  // --- UI เริ่มต้น ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // สีพื้นหลังของ Scaffold
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ให้ Card มีขนาดพอดีเนื้อหา
              children: [
                // --- Logo และ Title ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'MCCC',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.eco, color: Colors.green, size: 28),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Text(
                      'New Sample',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.agriculture_sharp, color: Colors.green, size: 28),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Tab Bar ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTab('Sample Info', true),
                    _buildTab('Environment', false),
                    _buildTab('Area History', false),
                  ],
                ),
                const SizedBox(height: 24),

                // --- ฟอร์มหลัก (ใช้ Expanded และ ListView เพื่อให้ Scroll ได้) ---
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero, // ลบ Padding เริ่มต้นของ ListView
                    children: [
                      // Sample Title
                      _buildTextFieldWithIcon(_sampleTitleController, 'Sample Title', Icons.search),
                      const SizedBox(height: 16),

                      // GPS Lat/Lon
                      _buildTextFieldWithIcon(_gpsController, 'GPS (Lat/Lon)', Icons.location_on, readOnly: true),
                      const SizedBox(height: 16),

                      // Place Name
                      _buildTextFieldWithIcon(_placeNameController, 'Place Name', Icons.home_work, readOnly: true),
                      const SizedBox(height: 16),

                      // --- Image Gallery ---
                      _buildImageGallery(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPhotoButton('Take Photo', Icons.camera_alt),
                          _buildPhotoButton('Pick Image', Icons.photo_library),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Logic to delete image
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Collection Date
                      _buildTextField(_collectionDateController, 'Collection Date'),
                      const SizedBox(height: 16),

                      // Description
                      _buildTextField(_descriptionController, 'Description'),
                      const SizedBox(height: 16),

                      // Organism
                      _buildTextField(_organismController, 'Organism'),
                      const SizedBox(height: 16),

                      // Environment Medium
                      _buildTextField(_environmentMediumController, 'Environment Medium'),
                      const SizedBox(height: 16),

                      // Collection Method
                      _buildTextField(_collectionMethodController, 'Collection Method'),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () {
                          // Logic to submit data
                          print('Submit button pressed!');
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  Widget _buildTextFieldWithIcon(TextEditingController controller, String labelText, IconData icon, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: Icon(icon, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 120, // ความสูงของแกลเลอรีรูปภาพ
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                if (_images.isNotEmpty) {
                  _currentImageIndex = (_currentImageIndex - 1 + _images.length) % _images.length;
                }
              });
            },
          ),
          Expanded(
            child: Center(
              child: _images.isNotEmpty
                  ? Image.network(
                      _images[_currentImageIndex],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Text('No Image'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() {
                if (_images.isNotEmpty) {
                  _currentImageIndex = (_currentImageIndex + 1) % _images.length;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoButton(String text, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {
        print('$text button pressed!');
        // Logic for taking/picking photo
      },
      icon: Icon(icon),
      label: Text(text),
    );
  }
}