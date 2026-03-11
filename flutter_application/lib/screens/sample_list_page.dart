import 'package:example/screens/mainShow.dart' show MainShowPage;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/MyDrawer.dart';

import '../models/sample.dart';
import '../services/sample_service.dart';
import '../widgets/sample_card.dart';

class SampleListPage extends StatefulWidget {
  // 1. เพิ่มบรรทัดนี้: ตัวแปรรับ Callback
  final Function(Widget?)? onPageChange; 

  // 2. เพิ่มใน Constructor: this.onPageChange
  const SampleListPage({
    super.key, 
    this.onPageChange, 
  });

  @override
  State<SampleListPage> createState() => _SampleListPageState();
}

class _SampleListPageState extends State<SampleListPage> {
  // Data
  List<Sample> _allFetchedSamples = [];
  List<Sample> _displayedSamples = [];
  List<Map<String, String>> _collectors = [];

  final Map<String, Map<String, dynamic>> _sampleDetails = {};

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String _userName = 'Loading...';
  String _userEmail = '';

  // Filters
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedCollectorId = '';

  // Title Filter
  String _selectedTitle = 'All';
  final List<String> _titles = [
    'All',
    'Soil',
    'Plant',
    'Water',
    'Insect',
  ];

  // provinces filter removed

  static const _gray = Color(0xFFE8F3EE);
  static const _green = Color(0xFF006A4E);
  static const Color kBgGreen = Color(0xFFF4F9F4);
  static const Color kPrimaryGreen = Color(0xFF006A4E);
  static const Color kSoftGreen = Color(0xFF4CAF8E);



  InputDecoration _fieldDecoration(String label, {IconData? icon}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF006A4E), fontSize: 12),
        prefixIcon:
            icon != null ? Icon(icon, color: Color(0xFF006A4E), size: 18) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        isDense: true,
      );

  @override
  void initState() {
    super.initState();
    //_searchController.addListener(_applyLocalFilters);
    _initData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyLocalFilters);
    _searchController.dispose();
    // organism controller removed
    super.dispose();
  }

  Future<void> _initData() async {
    await _loadUserProfile();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // ✅ key ตรงกับ LoginPage

    // โหลดรายชื่อ collectors (จาก service)
    try {
      final collectors = await SampleService.fetchCollectors(token);
      if (mounted) setState(() => _collectors = collectors);
    } catch (e) {
      debugPrint('Error loading collectors: $e');
    }

    // โหลดตัวอย่างตาม filter เริ่มต้น
    await _fetchAndApplySamples(token);
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Guest';
      _userEmail = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _fetchAndApplySamples(String? token) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final samples = await SampleService.fetchSamples(
        token: token,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        collectorId: _selectedCollectorId,
        name: _searchController.text,
        title: _selectedTitle,
      );

      debugPrint('Samples received: ${samples.length}');
      if (mounted) {
        setState(() {
          _allFetchedSamples = samples;
        });
      }

      // preload full details (from /samples/:id) so we can search organism/province
      await _preloadSampleDetails(samples, token);

      if (mounted) {
        setState(() {
          _applyLocalFilters();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _preloadSampleDetails(
      List<Sample> samples, String? token) async {
    for (final s in samples) {
      final id = s.id;
      if (id == null) continue;
      if (_sampleDetails.containsKey(id)) continue;
      try {
        final dynamic detailsRaw =
            await SampleService.fetchSampleById(id, token);
        Map<String, dynamic>? json;

        if (detailsRaw is Map<String, dynamic>) {
          json = detailsRaw;
        } else if (detailsRaw is Sample) {
          try {
            final dynamic maybe = (detailsRaw as Sample).toJson();
            if (maybe is Map<String, dynamic>) json = maybe;
          } catch (_) {
            json = null;
          }
        }

        if (json != null && json.isNotEmpty) _sampleDetails[id] = json;
      } catch (e) {
        debugPrint('Failed to load details for $id: $e');
      }
    }
  }

  void _applyLocalFilters() {
    final q = _searchController.text.trim().toLowerCase();
    List<Sample> temp = _allFetchedSamples;

    if (q.isNotEmpty) {
      temp = temp.where((s) {
        try {
          final List<String> values = [];

          final name = (s.sampName ?? '');
          final title = (s.sampTitle ?? '');
          if (name.isNotEmpty) values.add(name);
          if (title.isNotEmpty) values.add(title);

          // prefer cached full details when available
          final details = (s.id != null) ? _sampleDetails[s.id!] : null;

          // sample_info from cached JSON only
          final sampleInfo = details != null
              ? (details['sample_info'] ?? details['sampleInfo'])
                  as Map<String, dynamic>?
              : null;
          if (sampleInfo != null) {
            final org = sampleInfo['organism'] ??
                sampleInfo['Organism']; //filterหาชื่อเชื้อจุลินทรีย์
            if (org != null) values.add(org.toString());
          }

          // environment_info from cached JSON only
          //filterหาจังหวัดที่เก็บตัวอย่าง
          final env = details != null
              ? (details['environment_info'] ?? details['environmentInfo'])
                  as Map<String, dynamic>?
              : null;
          if (env != null) {
            final addr = env['address'];
            if (addr is Map) {
              if (addr['district'] != null)
                values.add(addr['district'].toString());
              if (addr['subdistrict'] != null)
                values.add(addr['subdistrict'].toString());
              if (addr['province'] != null)
                values.add(addr['province'].toString());
            }
            if (env['env_medium'] != null)
              values.add(env['env_medium'].toString());
          }

          return values.any((v) => v.toLowerCase().contains(q));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    if (_selectedTitle != 'All') {
      temp = temp
          .where((s) =>
              (s.sampTitle ?? '').toLowerCase() == _selectedTitle.toLowerCase())
          .toList();
    }

    setState(() {
      _displayedSamples = temp;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTitle = 'All';
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedCollectorId = '';
      // province cleared when filter removed
    });
    SharedPreferences.getInstance().then((prefs) {
      final token = prefs.getString('auth_token'); // ✅ key ตรงกับ LoginPage

      _fetchAndApplySamples(token);
    });
  }

@override
  Widget build(BuildContext context) {
    bool isFiltering = _searchController.text.isNotEmpty ||
        _selectedTitle != 'All' ||
        _selectedStartDate != null ||
        _selectedEndDate != null ||
        (_selectedCollectorId != null && _selectedCollectorId!.isNotEmpty);

    return Scaffold(
      backgroundColor: kBgGreen,
      
      // === แก้ไข AppBar ตรงนี้ ===
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        // toolbarHeight: 80, // <--- 1. ลบบรรทัดนี้ทิ้ง (เพื่อให้ใช้ความสูงมาตรฐาน)
        centerTitle: true,
        
        // 2. ปรับ Title ให้เป็น Text ธรรมดา ไม่ต้องใช้ Column
        title: const Text(
          'Sample List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20, // ลดขนาดลงนิดนึงให้พอดีกับมาตรฐาน (หรือใช้ 22 ตามเดิมก็ได้)
          ),
        ),
        elevation: 2,
      ),
      drawer: MyDrawer(
        userName: _userName,
        userEmail: _userEmail,
        activePage: "Search",
        // เพิ่มบรรทัดนี้ครับ 👇
        onMenuTap: (targetWidget) {
          // 1. ปิด Drawer ของหน้านี้ก่อน (เพราะมันเด้งมาทับหน้าจอ)
          Navigator.pop(context); 

          // 2. ถ้ามีฟังก์ชันส่งค่ากลับ (callback) ให้เรียกใช้มัน
          if (widget.onPageChange != null) {
            widget.onPageChange!(targetWidget);
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: _searchController,
                        // 1. กำหนดให้ปุ่ม Enter บนคีย์บอร์ดแสดงเป็นไอคอนค้นหา (เฉพาะมือถือ)
                        textInputAction: TextInputAction.search,

                        decoration:
                            _fieldDecoration('Search Name', icon: Icons.search),

                        // 2. สั่งให้ทำงานเมื่อกด Enter
                        onSubmitted: (value) async {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('auth_token'); // ✅ key ตรงกับ LoginPage


                          // Debug ให้เห็นว่ากด Enter แล้ว
                          debugPrint('Enter key pressed searching for: $value');

                          await _fetchAndApplySamples(token);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildDateButton(
                        label: 'Start Date',
                        date: _selectedStartDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedStartDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _selectedStartDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: _buildDateButton(
                        label: 'End Date',
                        date: _selectedEndDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedEndDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _selectedEndDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: InputDecorator(
                        decoration:
                            _fieldDecoration('Title', icon: Icons.category),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTitle,
                            isDense: true,
                            isExpanded: true,
                            items: _titles
                                .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) {
                              setState(() => _selectedTitle = val!);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: InputDecorator(
                        decoration:
                            _fieldDecoration('Collector', icon: Icons.person),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCollectorId,
                            isDense: true,
                            isExpanded: true,
                            hint: const Text("All",
                                style: TextStyle(fontSize: 13)),
                            items: _collectors.map((c) {
                              return DropdownMenuItem(
                                value: c['id'],
                                child: Text(c['name']!,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedCollectorId = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // organism and province filters removed
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('auth_token'); // ✅ key ตรงกับ LoginPage


                      debugPrint(
                          'Search params -> start: $_selectedStartDate end: $_selectedEndDate collector: $_selectedCollectorId title: $_selectedTitle name: ${_searchController.text}');

                      await _fetchAndApplySamples(token);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text(
                      "Search Filters",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (isFiltering)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF006A4E)),
                        label: const Text("Clear All Filters",
                            style: TextStyle(color: Color(0xFF006A4E), fontSize: 13)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)))
                    : _displayedSamples.isEmpty
                        ? const Center(
                            child: Text('ไม่พบข้อมูล',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)))
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                                bottom: 80, left: 16, right: 16),
                            itemCount: _displayedSamples.length,
                            itemBuilder: (context, index) {
                              final sample = _displayedSamples[index];
                              return SampleCard(
                                sample: sample,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MainShowPage(
                                          sampName: '${sample.sampName}'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
      {required String label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          // เปลี่ยนสีขอบถ้ามีการเลือกวันที่แล้ว
          border: date != null
              ? Border.all(color: kPrimaryGreen) // สีเขียว _green
              : Border.all(color: Colors.transparent), // หรือสีเทาอ่อนๆ
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. แสดงชื่อ Label (เช่น Start, End)
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),

            // 3. เงื่อนไขการแสดงผล: ถ้ามีวันที่โชว์วันที่, ถ้าไม่มีโชว์ไอคอน
            if (date != null)
              Text(
                DateFormat('dd/MM/yyyy').format(date), // ปรับ format ตามชอบ
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF004D40),
                    fontWeight: FontWeight.bold),
              )
            else
              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF4CAF8E)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
  