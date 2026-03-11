import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class LabService {
  static const String baseUrl = 'https://mccc-api.onrender.com';

  static Future<void> updateLabBySampleName({
    required String sampleName,
    required Map<String, dynamic> labResult,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/samples/name/$sampleName');

    debugPrint('PUT LAB -> $uri');

    final resp = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "lab_result": labResult, 
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Update lab failed: ${resp.statusCode}');
    }
  }
}
