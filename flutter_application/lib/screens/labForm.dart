import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:example/models/labSample.dart';

class LabFormWidget extends StatefulWidget {
  final LabSample? initialLab;
  final String sampleName;
  final Function(LabSample)? onSaved;

  const LabFormWidget({
    super.key,
    required this.sampleName,
    this.initialLab,
    this.onSaved,
  });

  @override
  State<LabFormWidget> createState() => _LabFormWidgetState();
}

class _LabFormWidgetState extends State<LabFormWidget> {
  static const baseUrl = 'https://mccc-api.onrender.com';

  // 🌿 KU GREEN
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color softGreen = Color(0xFFF1F8E9);

  // ───────── Controllers ─────────
  final pHCtrl = TextEditingController();
  final orgCCtrl = TextEditingController();
  final nCtrl = TextEditingController();
  final pCtrl = TextEditingController();
  final kCtrl = TextEditingController();
  final textureCtrl = TextEditingController();

  final List<Map<String, TextEditingController>> microbeCtrls = [];

  bool get isEdit => widget.initialLab != null;

  // ───────── Init ─────────
  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadInitialData(widget.initialLab!);
    } else {
      _addMicrobe();
    }
  }

  void _loadInitialData(LabSample lab) {
    pHCtrl.text = lab.pH?.toString() ?? "";
    orgCCtrl.text = lab.organicCarbon?.toString() ?? "";
    nCtrl.text = lab.nitrogen?.toString() ?? "";
    pCtrl.text = lab.phosphorus?.toString() ?? "";
    kCtrl.text = lab.potassium?.toString() ?? "";
    textureCtrl.text = lab.texture;

    microbeCtrls.clear();
    if (lab.microbeAnalysis.isNotEmpty) {
      for (final m in lab.microbeAnalysis) {
        microbeCtrls.add({
          "method": TextEditingController(text: m["method"]),
          "results_summary":
              TextEditingController(text: m["results_summary"]),
          "data_file_url":
              TextEditingController(text: m["data_file_url"]),
        });
      }
    } else {
      _addMicrobe();
    }
  }

  void _addMicrobe() {
    microbeCtrls.add({
      "method": TextEditingController(),
      "results_summary": TextEditingController(),
      "data_file_url": TextEditingController(),
    });
  }

  // ───────── Save ─────────
  Future<void> _saveLab() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final body = {
      "lab.ph": double.tryParse(pHCtrl.text),
      "lab.organicCarbon": double.tryParse(orgCCtrl.text),
      "lab.nitrogen": double.tryParse(nCtrl.text),
      "lab.phosphorus": double.tryParse(pCtrl.text),
      "lab.potassium": double.tryParse(kCtrl.text),
      "lab.texture": textureCtrl.text,
      "lab.microbeAnalysis": microbeCtrls
          .map((c) => {
                "method": c["method"]!.text,
                "results_summary": c["results_summary"]!.text,
                "data_file_url": c["data_file_url"]!.text,
              })
          .where((m) => m.values.any((v) => v.trim().isNotEmpty))
          .toList(),
    };

    try {
      final resp = await http.put(
        Uri.parse('$baseUrl/samples/name/${widget.sampleName}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode != 200) {
        throw Exception(resp.body);
      }

      final lab = LabSample(
        pH: double.tryParse(pHCtrl.text),
        organicCarbon: double.tryParse(orgCCtrl.text),
        nitrogen: double.tryParse(nCtrl.text),
        phosphorus: double.tryParse(pCtrl.text),
        potassium: double.tryParse(kCtrl.text),
        texture: textureCtrl.text,
        microbeAnalysis: microbeCtrls
            .where((c) =>
                c["method"]!.text.isNotEmpty ||
                c["results_summary"]!.text.isNotEmpty ||
                c["data_file_url"]!.text.isNotEmpty)
            .map((c) => {
                  "method": c["method"]!.text,
                  "results_summary": c["results_summary"]!.text,
                  "data_file_url": c["data_file_url"]!.text,
                })
            .toList(),
      );

      if (mounted) {
        if (widget.onSaved != null) {
          widget.onSaved!(lab); // ใช้ใน Tab
        } else {
          Navigator.pop(context, lab); // ใช้กับ push
        }
      }
    } catch (e) {
      _error("Save failed: $e");
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ❌ ไม่มีปุ่มย้อนกลับ
        title: Text(isEdit ? "Edit Lab Data" : "Add Lab Data"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionCard(
              title: "Soil Chemical Properties",
              children: [
                _numField("pH", pHCtrl, Icons.science),
                _numField("Organic Carbon (%)", orgCCtrl, Icons.eco),
                _numField("Nitrogen (%)", nCtrl, Icons.bubble_chart),
                _numField("Phosphorus (mg/kg)", pCtrl, Icons.grain),
                _numField("Potassium (mg/kg)", kCtrl, Icons.local_florist),
                _textField("Soil Texture", textureCtrl, Icons.texture),
              ],
            ),
            const SizedBox(height: 24),
            _sectionCard(
              title: "Microbial Analysis",
              children: [
                ...List.generate(
                  microbeCtrls.length,
                  (i) => _microbeForm(i, microbeCtrls[i]),
                ),
                TextButton.icon(
                  onPressed: () => setState(_addMicrobe),
                  icon: const Icon(Icons.add, color: primaryGreen),
                  label: const Text(
                    "Add Microbial Analysis",
                    style: TextStyle(color: primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveLab,
                icon: const Icon(Icons.save),
                label: Text(
                  isEdit ? "UPDATE LAB DATA" : "SAVE LAB DATA",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Widgets ─────────
  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _microbeForm(
    int index,
    Map<String, TextEditingController> m,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Microbe ${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    microbeCtrls.removeAt(index);
                  });
                },
              ),
            ],
          ),
          _textField("Method", m["method"]!, Icons.biotech),
          _textField("Results Summary", m["results_summary"]!, Icons.description),
          _textField("Data File URL", m["data_file_url"]!, Icons.link),
        ],
      ),
    );
  }

  Widget _numField(
      String label, TextEditingController c, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _textField(
      String label, TextEditingController c, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryGreen),
      filled: true,
      fillColor: softGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: primaryGreen, width: 2),
      ),
    );
  }
}
