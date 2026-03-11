
import 'package:example/models/labSample.dart';
import 'package:example/screens/labShow.dart';
import 'package:example/screens/labForm.dart';
import 'package:flutter/material.dart';

class LabDetailPage extends StatefulWidget {
  final LabSample lab;

  const LabDetailPage({super.key, required this.lab});

  @override
  State<LabDetailPage> createState() => _LabDetailPageState();
}

class _LabDetailPageState extends State<LabDetailPage> {
  late LabSample _lab;

  @override
  void initState() {
    super.initState();
    _lab = widget.lab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lab Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LabInfoDisplay(
          lab: _lab,

          /// ⭐ ตรงนี้คือการเชื่อมปุ่ม Edit
          onEdit: () async {
            final updatedLab = await Navigator.push<LabSample>(
              context,
              MaterialPageRoute(
                builder: (_) => LabFormWidget(
                  initialLab: _lab, sampleName: '', // ส่งข้อมูลเดิมไปแก้
                ),
              ),
            );

            /// ถ้ากด save กลับมา
            if (updatedLab != null) {
              setState(() {
                _lab = updatedLab;
              });
            }
          },
        ),
      ),
    );
  }
}
