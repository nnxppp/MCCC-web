import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sample.dart'; // ตรวจสอบ path

class SampleProvider extends ChangeNotifier {
  // Data
  List<Sample> _allSamples = [];
  List<Sample> _filteredSamples = [];
  List<Map<String, String>> _collectors = [];
  
  // Status
  bool _loading = false;
  String? _errorMessage;

  // Filters
  String _searchName = '';
  String? _selectedTitle = 'All'; // (ใหม่) กรอง Title
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedCollectorId;

  // Getters
  List<Sample> get sampleData => _filteredSamples;
  List<Map<String, String>> get collectors => _collectors;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  
  String get searchName => _searchName;
  String? get selectedTitle => _selectedTitle;
  DateTime? get selectedDate => _selectedStartDate; // Alias for start date
  DateTime? get startDate => _selectedStartDate;
  DateTime? get endDate => _selectedEndDate;
  String? get selectedCollectorId => _selectedCollectorId;

  final List<String> titles = ['All', 'Soil', 'Plant', 'Water', 'Insect'];

  SampleProvider() {
    _initData();
  }

  Future<void> _initData() async {
    await fetchCollectors();
    await fetchSamples();
  }

  // ----------------------------
  // 1. ดึงรายชื่อ Collector
  // ----------------------------
  Future<void> fetchCollectors() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // เช็ค token
      if (token == null || token.isEmpty) {
        _errorMessage = 'Token not found. Please login first.';
        _loading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('https://mccc-api.onrender.com/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _collectors = data.map((e) => {
          'id': e['_id'].toString(),
          'name': e['name'].toString(),
        }).toList();
        _collectors.insert(0, {'id': '', 'name': 'All Collectors'});
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else {
        _errorMessage = 'Failed to fetch collectors: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching collectors: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // 2. ดึงข้อมูล Sample
  // ----------------------------
  Future<void> fetchSamples() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // เช็ค token
      if (token == null || token.isEmpty) {
        _errorMessage = 'Token not found. Please login first.';
        _loading = false;
        notifyListeners();
        return;
      }

      Map<String, String> queryParams = {};
      
      if (_selectedStartDate != null) {
        queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
      }
      if (_selectedEndDate != null) {
        queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(_selectedEndDate!);
      }
      if (_selectedCollectorId != null && _selectedCollectorId!.isNotEmpty) {
        queryParams['collectorId'] = _selectedCollectorId!;
      }

      final uri = Uri.parse('https://mccc-api.onrender.com/samples')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allSamples = data.map((e) => Sample.fromJson(e)).toList();
        _applyLocalFilters(); 
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else {
        _errorMessage = 'Failed to fetch samples: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching samples: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // 3. กรองข้อมูลในเครื่อง (Name & Title)
  // ----------------------------
  void _applyLocalFilters() {
    List<Sample> temp = _allSamples;

    // กรองชื่อ
    if (_searchName.isNotEmpty) {
      temp = temp.where((s) => 
        s.sampName.toLowerCase().contains(_searchName.toLowerCase())
      ).toList();
    }

    // กรอง Title
    if (_selectedTitle != null && _selectedTitle != 'All') {
      temp = temp.where((s) => 
        s.sampTitle.toLowerCase() == _selectedTitle!.toLowerCase()
      ).toList();
    }

    _filteredSamples = temp;
  }

  // ----------------------------
  // Setter Methods
  // ----------------------------
  void setSearchName(String query) {
    _searchName = query;
    _applyLocalFilters();
    notifyListeners();
  }

  void setTitle(String? title) {
    _selectedTitle = title;
    _applyLocalFilters();
    notifyListeners();
  }

  void setCollector(String? id) {
    _selectedCollectorId = id;
    fetchSamples();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _selectedStartDate = start;
    _selectedEndDate = end;
    fetchSamples();
  }

  void clearFilters() {
    _searchName = '';
    _selectedTitle = 'All';
    _selectedStartDate = null;
    _selectedEndDate = null;
    _selectedCollectorId = '';
    fetchSamples();
  }
  
  String formatThaiDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
