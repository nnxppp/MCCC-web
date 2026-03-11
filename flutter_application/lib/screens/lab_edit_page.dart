import 'package:flutter/material.dart';

class LabEditPage extends StatefulWidget {
  // 1. ประกาศตัวแปรที่จะรับ (เช่น Map หรือ Model)
  final Map<String, dynamic> sample; 

  // 2. รับค่าผ่าน Constructor
  const LabEditPage({super.key, required this.sample});

  @override
  State<LabEditPage> createState() => _LabEditPageState();
}

class _LabEditPageState extends State<LabEditPage> {
  // ตัวควบคุม TextField (ถ้าต้องแก้ไขข้อมูล)
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // 3. ดึงข้อมูลมาใช้ โดยใช้คำสั่ง widget.sample['คีย์']
    // เช่น ดึงชื่อตัวอย่างมาใส่ใน TextField
    String initialName = widget.sample['samp_name'] ?? ''; 
    _nameController = TextEditingController(text: initialName);
    
    // ลองปริ้นดูค่าที่รับมา
    print("รับข้อมูลมาแล้ว: ${widget.sample}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขข้อมูล")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // แสดงข้อมูลที่รับมา
            Text("ID: ${widget.sample['_id']}"), 
            
            const SizedBox(height: 20),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Sample Name'),
            ),
            
            // ... ส่วนอื่นๆ ของหน้า
          ],
        ),
      ),
    );
  }
}