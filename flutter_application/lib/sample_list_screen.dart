// import 'dart:convert';

// import 'package:example/screens/mainShow.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Sample {
//   final String id;
//   final String sampName;
//   final String sampTitle;
//   final DateTime collectionDate;
//   final String collectedBy;
//   final String collectedByName;
//   final String? pictureUrl;

//   Sample({
//     required this.id,
//     required this.sampName,
//     required this.sampTitle,
//     required this.collectionDate,
//     required this.collectedBy,
//     required this.collectedByName,
//     this.pictureUrl,
//   });

//   factory Sample.fromJson(Map<String, dynamic> json) {
//     final collectedByData = json['collected_by'];
//     final collectedByString = collectedByData is Map
//         ? collectedByData['_id'] as String? ?? ''
//         : collectedByData as String? ?? '';
//     final collectedByName = collectedByData is Map
//         ? collectedByData['name'] as String? ?? 'Unknown'
//         : 'Unknown';
//     final sampleInfo = json['sample_info'] as Map<String, dynamic>?;
//     final List<dynamic>? pictures = sampleInfo?['picture'] as List<dynamic>?;
//     final String? firstPictureUrl = pictures != null && pictures.isNotEmpty
//         ? pictures.first as String?
//         : null;
//     return Sample(
//       id: json['_id'] as String,
//       sampName: json['samp_name'] as String,
//       sampTitle: sampleInfo?['samp_title'] as String? ?? 'N/A',
//       collectionDate: sampleInfo?['collection_date'] != null
//           ? DateTime.parse(sampleInfo!['collection_date'] as String)
//           : DateTime.now(),
//       collectedBy: collectedByString,
//       collectedByName: collectedByName,
//       pictureUrl: firstPictureUrl,
//     );
//   }
// }

// class SampleListScreen extends StatefulWidget {
//   const SampleListScreen({Key? key}) : super(key: key);

//   @override
//   State<SampleListScreen> createState() => _SampleListScreenState();
// }

// class _SampleListScreenState extends State<SampleListScreen> {
//   List<Sample> _samples = [];
//   List<Map<String, String>> _collectors = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;
//   String? _selectedCollectorId = '';

//   static const _gray = Color.fromARGB(255, 226, 233, 235);
//   static const _green = Color.fromARGB(255, 88, 144, 75);

//   InputDecoration _fieldDecoration(String label, {IconData? icon}) =>
//       InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(
//           color: Colors.black,
//           fontWeight: FontWeight.normal,
//         ),
//         prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
//         border: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         errorBorder: InputBorder.none,
//         focusedErrorBorder: InputBorder.none,
//         fillColor: Colors.white,
//         filled: true,
//         contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
//       );

//   final ButtonStyle _primaryBtnStyle = ElevatedButton.styleFrom(
//     backgroundColor: _green,
//     foregroundColor: Colors.white,
//     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//   );

// final TextEditingController _startDateController = TextEditingController();
// final TextEditingController _endDateController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Set default start/end date to today
//     final today = DateTime.now();
//     _selectedStartDate = today;
//     _selectedEndDate = today;
//     fetchCollectorsAndSetDefault();
//   }

//   Future<void> fetchCollectorsAndSetDefault() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//       final userId = prefs.getString('user_id');
//       final userRole = prefs.getString('user_role');
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Authentication token not found.';
//           _isLoading = false;
//         });
//         return;
//       }
//       final response = await http.get(
//         Uri.parse('https://mccc-api.onrender.com/users'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> userData = json.decode(response.body);
//         final collectorsList = userData
//             .map(
//               (user) => {
//                 'id': user['_id'] as String,
//                 'name': user['name'] as String,
//               },
//             )
//             .toList();
//         collectorsList.insert(0, {'id': '', 'name': 'All Collectors'});

//         String defaultCollectorId = '';
//         if (userRole == 'collector' && userId != null) {
//           final found = collectorsList.firstWhere(
//             (c) => c['id'] == userId,
//             orElse: () => {'id': '', 'name': 'All Collectors'},
//           );
//           defaultCollectorId = found['id'] ?? '';
//         }

//         setState(() {
//           _collectors = collectorsList;
//           _selectedCollectorId = defaultCollectorId;
//         });

//         // หลังจาก set ค่า default แล้ว ให้ fetch samples ใหม่
//         fetchSamples();
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load collectors: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching collectors: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchSamples() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//       if (token == null) {
//         setState(() {
//           _errorMessage = 'Authentication token not found.';
//           _isLoading = false;
//         });
//         return;
//       }
//       final Map<String, String> queryParams = {};
//       if (_selectedStartDate != null) {
//         queryParams['startDate'] = DateFormat(
//           'yyyy-MM-dd',
//         ).format(_selectedStartDate!);
//       }
//       if (_selectedEndDate != null) {
//         queryParams['endDate'] = DateFormat(
//           'yyyy-MM-dd',
//         ).format(_selectedEndDate!);
//       }
//       if (_selectedCollectorId != null && _selectedCollectorId!.isNotEmpty) {
//         queryParams['collectorId'] = _selectedCollectorId!;
//       }
//       final uri = Uri.parse(
//         'https://mccc-api.onrender.com/samples',
//       ).replace(queryParameters: queryParams);
//       final response = await http.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> sampleData = json.decode(response.body);
//         setState(() {
//           _samples = sampleData.map((json) => Sample.fromJson(json)).toList();
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load samples: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching samples: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _gray,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         toolbarHeight: 80,
//         centerTitle: true,
//         title: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset(
//               'assets/mccc.png',
//               width: MediaQuery.of(context).size.width / 5,
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) => const Icon(
//                 Icons.image_not_supported,
//                 size: 38,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Sample List',
//                   style: TextStyle(
//                     color: Color(0xFF444444),
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 3),
//                 Image.asset(
//                   'assets/leaf.png',
//                   width: 25,
//                   height: 25,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) =>
//                       const Icon(Icons.eco, size: 24, color: Colors.green),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         elevation: 2,
//       ),
//       body: _isLoading && _samples.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//           ? Center(
//               child: Text(
//                 'Error: $_errorMessage',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             )
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       // Start/End date in one row
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () async {
//                                 DateTime? pickedDate = await showDatePicker(
//                                   context: context,
//                                   initialDate:
//                                       _selectedStartDate ?? DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2101),
//                                 );
//                                 if (pickedDate != null) {
//                                   setState(() {
//                                     _selectedStartDate = pickedDate;
//                                   });
//                                 }
//                               },
//                               child: AbsorbPointer(
//                                 child: TextFormField(
//                                   decoration: _fieldDecoration(
//                                     'Start Date',
//                                     icon: Icons.calendar_today,
//                                   ),
//                                   controller: TextEditingController(
//                                     text: _selectedStartDate == null
//                                         ? ''
//                                         : DateFormat(
//                                             'yyyy-MM-dd',
//                                           ).format(_selectedStartDate!),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () async {
//                                 DateTime? pickedDate = await showDatePicker(
//                                   context: context,
//                                   initialDate:
//                                       _selectedEndDate ?? DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2101),
//                                 );
//                                 if (pickedDate != null) {
//                                   setState(() {
//                                     _selectedEndDate = pickedDate;
//                                   });
//                                 }
//                               },
//                               child: AbsorbPointer(
//                                 child: TextFormField(
//                                   decoration: _fieldDecoration(
//                                     'End Date',
//                                     icon: Icons.calendar_today,
//                                   ),
//                                   controller: TextEditingController(
//                                     text: _selectedEndDate == null
//                                         ? ''
//                                         : DateFormat(
//                                             'yyyy-MM-dd',
//                                           ).format(_selectedEndDate!),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           if (_selectedStartDate != null)
//                             TextButton(
//                               onPressed: () => setState(() {
//                                 _selectedStartDate = null;
//                               }),
//                               child: const Text('Clear Start'),
//                             ),
//                           if (_selectedEndDate != null)
//                             TextButton(
//                               onPressed: () => setState(() {
//                                 _selectedEndDate = null;
//                               }),
//                               child: const Text('Clear End'),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       DropdownButtonFormField<String>(
//                         decoration: _fieldDecoration(
//                           'Filter by Collector',
//                           icon: Icons.person,
//                         ),
//                         value: _selectedCollectorId,
//                         items: _collectors.map((collector) {
//                           return DropdownMenuItem<String>(
//                             value: collector['id'],
//                             child: Text(collector['name']!),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedCollectorId = value;
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: _primaryBtnStyle,
//                           onPressed: fetchSamples,
//                           child: const Text('Search Samples'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: _samples.isEmpty
//                       ? const Center(child: Text('No samples found.'))
//                       : ListView.builder(
//                           itemCount: _samples.length,
//                           itemBuilder: (context, index) {
//                             final sample = _samples[index];
//                             return InkWell(
//                               onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (_) => MainShowPage(sampName: '${sample.sampName}'),
//                                             ),
//                                           );

//                               },

//                               child: Card(
//                                 margin: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                   horizontal: 16,
//                                 ),
//                                 elevation: 2,
//                                 child: Row(
//                                   children: [
//                                     sample.pictureUrl != null
//                                         ? Image.network(
//                                             sample.pictureUrl!,
//                                             width: 80,
//                                             height: 80,
//                                             fit: BoxFit.cover,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) =>
//                                                     const Icon(
//                                                       Icons.broken_image,
//                                                       size: 80,
//                                                     ),
//                                           )
//                                         : const Icon(Icons.image, size: 80),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 12.0,
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               sample.sampName,
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               'Date: ${DateFormat('yyyy-MM-dd').format(sample.collectionDate)}',
//                                             ),
//                                             Text(
//                                               'Collector: ${sample.collectedByName}',
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
