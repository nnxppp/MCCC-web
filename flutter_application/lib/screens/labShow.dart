import 'package:flutter/material.dart';
import 'package:example/models/labSample.dart';

class LabInfoDisplay extends StatelessWidget {
  final LabSample lab;
  final VoidCallback onEdit;

  const LabInfoDisplay({
    super.key,
    required this.lab,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> soilMap = {
      "pH": lab.pH?.toString() ?? "",
      "Organic Carbon (%)": lab.organicCarbon?.toString() ?? "",
      "Nitrogen (%)": lab.nitrogen?.toString() ?? "",
      "Phosphorus (mg/kg)": lab.phosphorus?.toString() ?? "",
      "Potassium (mg/kg)": lab.potassium?.toString() ?? "",
      "Soil Texture": lab.texture,
    };

    return Card(
      elevation: 4,
      color: const Color(0xFFF1F8E9), // 🌿 เขียวอ่อน
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- Header ----------
            Row(
              children: [
                const Icon(Icons.science, color: Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                const Text(
                  "Laboratory Results",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: const Color(0xFF2E7D32),
                  tooltip: "Edit Lab Data",
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 22),

            /// ---------- Soil Analysis ----------
            _sectionTitle("Soil Analysis"),
            const SizedBox(height: 12),
            ...soilMap.entries
                .where((e) => e.value.trim().isNotEmpty)
                .map((e) => _infoRow(e.key, e.value))
                .toList(),

            /// ---------- Microbial Analysis ----------
            if (lab.microbeAnalysis.isNotEmpty) ...[
              const SizedBox(height: 28),
              _sectionTitle("Microbial Analysis"),
              const SizedBox(height: 14),
              ...lab.microbeAnalysis.map(_microbeCard).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Color(0xFF388E3C), // 🌿 เขียวกลาง
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF558B2F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1B5E20),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Color(0xFFC8E6C9)),
        ],
      ),
    );
  }

  Widget _microbeCard(Map<String, String> microbe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            microbe['method'] ?? "",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            microbe['results_summary'] ?? "",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF33691E),
              height: 1.4,
            ),
          ),
          if ((microbe['data_file_url'] ?? "").isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              microbe['data_file_url']!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF689F38),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
