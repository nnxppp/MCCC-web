import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sample.dart';

class SampleService {
  static const String baseUrl = 'https://mccc-api.onrender.com';

  // =========================
  // Collectors
  // =========================
  static Future<List<Map<String, String>>> fetchCollectors(
      String? token) async {
    final uri = Uri.parse('$baseUrl/users');
    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      final collectors = data
          .map<Map<String, String>>(
            (u) => {
              'id': u['_id']?.toString() ?? '',
              'name': u['name']?.toString() ?? 'Unknown',
            },
          )
          .toList();

      collectors.insert(0, {'id': '', 'name': 'All'});
      return collectors;
    }

    throw Exception('Failed to load collectors: ${resp.statusCode}');
  }

  // =========================
  // Fetch Samples (with filters) -> Sample model
  // =========================
  static Future<List<Sample>> fetchSamples({
    required String? token,
    DateTime? startDate,
    DateTime? endDate,
    String? collectorId,
    String? name,
    String? title,
    String? organism,
    String? envMedium,
    String? province,
    int? minAlt,
    int? maxAlt,
  }) async {
    final Map<String, String> qp = {};

    if (startDate != null) {
      qp['startDate'] = DateFormat('yyyy-MM-dd').format(startDate);
    }
    if (endDate != null) {
      qp['endDate'] = DateFormat('yyyy-MM-dd').format(endDate);
    }
    if (collectorId != null && collectorId.isNotEmpty) {
      qp['collectorId'] = collectorId;
    }
    if (name != null && name.isNotEmpty) qp['name'] = name;
    if (title != null && title.isNotEmpty && title != 'All') {
      qp['title'] = title;
    }
    if (organism != null && organism.isNotEmpty) {
      qp['organism'] = organism;
    }
    if (envMedium != null && envMedium.isNotEmpty) {
      qp['env_medium'] = envMedium;
    }
    if (province != null && province.isNotEmpty) {
      qp['province'] = province;
    }
    if (minAlt != null) qp['minAlt'] = minAlt.toString();
    if (maxAlt != null) qp['maxAlt'] = maxAlt.toString();

    final uri =
        Uri.parse('$baseUrl/samples').replace(queryParameters: qp);

    debugPrint('SampleService.fetchSamples GET -> $uri');

    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    debugPrint(
      'SampleService.fetchSamples status=${resp.statusCode} bodyLen=${resp.body.length}',
    );

    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data
          .map((j) => Sample.fromJson(j as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load samples: ${resp.statusCode}');
  }

  // =========================
  // Fetch Sample by ID -> Sample model
  // =========================
  static Future<Sample> fetchSampleById(String id, String? token) async {
    final uri = Uri.parse('$baseUrl/samples/$id');
    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      return Sample.fromJson(json.decode(resp.body));
    }

    throw Exception('Failed to load sample: ${resp.statusCode}');
  }

  // =========================
  // Fetch Sample by Name -> Sample model
  // =========================
  static Future<Sample> fetchSampleByName(
      String name, String? token) async {
    final uri = Uri.parse('$baseUrl/samples/name/$name');
    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      return Sample.fromJson(json.decode(resp.body));
    }

    throw Exception(
        'Failed to load sample by name: ${resp.statusCode}');
  }

  // =========================
  // Raw JSON (legacy / simple usage)
  // =========================

  /// ดึง Sample ทั้งหมด (raw json)
  static Future<List<dynamic>?> fetchAllSamplesRaw() async {
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/samples'),
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else {
        debugPrint('Error: ${resp.statusCode}');
        debugPrint(resp.body);
      }
    } catch (e) {
      debugPrint('Exception: $e');
    }
    return null;
  }

  /// ดึง Sample ตามชื่อ (raw json)
  static Future<Map<String, dynamic>?> fetchSampleByNameRaw(
      String sampName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final resp = await http.get(
        Uri.parse('$baseUrl/samples/name/$sampName'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('STATUS: ${resp.statusCode}');
      debugPrint('RESP BODY: ${resp.body}');

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else {
        debugPrint('API ERROR ${resp.statusCode}');
        debugPrint(resp.body);
      }
    } catch (e) {
      debugPrint('Exception: $e');
    }
    return null;
  }
}
