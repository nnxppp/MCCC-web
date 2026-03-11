// ...existing code...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sample.dart';

class SampleCard extends StatelessWidget {
  final Sample sample;
  final VoidCallback? onTap;
  static const _green = Color(0xFF58904B);

  const SampleCard({super.key, required this.sample, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: SizedBox(
                width: 100,
                height: 130,
                child: sample.pictureUrl != null
                    ? Image.network(sample.pictureUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)))
                    : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 40, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sample.sampName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(sample.sampTitle, style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  if (sample.organism != null && sample.organism!.isNotEmpty) _buildInfoRow(Icons.bug_report, sample.organism!, Colors.orange),
                  if (sample.bioprojectId != null && sample.bioprojectId!.isNotEmpty) _buildInfoRow(Icons.science, sample.bioprojectId!, Colors.blue),
                  const Divider(height: 12, thickness: 0.5),
                  Row(children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(sample.collectionDate != null ? DateFormat('dd/MM/yy').format(sample.collectionDate!) : '-', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(width: 10),
                    Icon(Icons.person_outline, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(child: Text(sample.collectedByName, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ])
                ]),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 55, right: 8.0), child: Icon(Icons.chevron_right, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(children: [Icon(icon, size: 14, color: iconColor), const SizedBox(width: 4), Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[800]), maxLines: 1, overflow: TextOverflow.ellipsis)),]),
    );
  }
}
// ...existing code...