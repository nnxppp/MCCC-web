class LabSample {
  /// -------- soil_analysis --------
  double? pH;
  double? organicCarbon;
  double? nitrogen;
  double? phosphorus;
  double? potassium;
  String texture;

  /// -------- microbe_analysis --------
  /// ใช้ List<Map<String,String>> แทน class
  List<Map<String, String>> microbeAnalysis;

  LabSample({
    this.pH,
    this.organicCarbon,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.texture = "",
    this.microbeAnalysis = const [],
  });

  /// ---------- fromJson ----------
  factory LabSample.fromJson(Map<String, dynamic> json) {
  final soil = json['soil_analysis'] ?? {};

  return LabSample(
    pH: soil['pH']?.toDouble(),
    organicCarbon: soil['organic_carbon']?.toDouble(),
    nitrogen: soil['nitrogen']?.toDouble(),
    phosphorus: soil['phosphorus']?.toDouble(),
    potassium: soil['potassium']?.toDouble(),
    texture: soil['texture']?.toString() ?? "",

    microbeAnalysis: (json['microbe_analysis'] as List<dynamic>?)
            ?.map((e) => {
                  "method": e['method']?.toString() ?? "",
                  "results_summary":
                      e['results_summary']?.toString() ?? "",
                  "data_file_url":
                      e['data_file_url']?.toString() ?? "",
                })
            .toList() ??
        [],
  );
}


  /// ---------- toJson ----------
  Map<String, dynamic> toJson() {
  return {
    "soil_analysis": {
      "pH": pH,
      "organic_carbon": organicCarbon,
      "nitrogen": nitrogen,
      "phosphorus": phosphorus,
      "potassium": potassium,
      "texture": texture,
    },
    "microbe_analysis": microbeAnalysis,
  };
}


  /// ---------- check has data ----------
  bool get hasData {
    return pH != null ||
        organicCarbon != null ||
        nitrogen != null ||
        phosphorus != null ||
        potassium != null ||
        texture.isNotEmpty ||
        microbeAnalysis.isNotEmpty;
  }

  @override
  String toString() {
    return 'LabSample(pH: $pH, organicCarbon: $organicCarbon, nitrogen: $nitrogen, '
        'phosphorus: $phosphorus, potassium: $potassium, texture: $texture, '
        'microbeAnalysis: $microbeAnalysis)';
  }
}