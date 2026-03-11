class Sample {
  final String id;
  final String sampName;
  final String sampTitle;
  final String organism;
  final String bioprojectId;
  final DateTime? collectionDate;
  final String collectedById;     // <-- เพิ่ม
  final String collectedByName;
  final String? pictureUrl;

  Sample({
    required this.id,
    required this.sampName,
    required this.sampTitle,
    required this.organism,
    required this.bioprojectId,
    this.collectionDate,
    required this.collectedById,   // <-- required
    required this.collectedByName,
    this.pictureUrl,
  });

  factory Sample.fromJson(Map<String, dynamic> json) {
    final sampleInfo = json['sample_info'] as Map<String, dynamic>? ?? {};
    final collector = json['collected_by'] as Map<String, dynamic>?;

    String cName = 'Unknown';
    String cId = '';
    if (collector != null) {
      cName = collector['name']?.toString() ?? 'Unknown';
      cId = collector['_id']?.toString() ?? '';
    }

    DateTime? cDate;
    if (sampleInfo['collection_date'] != null) {
      try {
        cDate = DateTime.parse(sampleInfo['collection_date'].toString());
      } catch (_) {}
    }

    String? picUrl;
    if (sampleInfo['picture'] != null && (sampleInfo['picture'] as List).isNotEmpty) {
      picUrl = sampleInfo['picture'][0]?.toString();
    }

    return Sample(
      id: json['_id']?.toString() ?? '',
      sampName: json['samp_name']?.toString() ?? '-',
      sampTitle: sampleInfo['samp_title']?.toString() ?? '-',
      organism: sampleInfo['organism']?.toString() ?? '-',
      bioprojectId: sampleInfo['bioproject_id']?.toString() ?? '-',
      collectionDate: cDate,
      collectedById: cId,       // <-- เพิ่มตรงนี้
      collectedByName: cName,
      pictureUrl: picUrl,
    );
  }
}
