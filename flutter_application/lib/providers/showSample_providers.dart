import 'package:flutter/material.dart';
import 'package:example/services/sample_service.dart';
import 'package:example/models/sample.dart';

class ShowsampleProviders with ChangeNotifier {
  List<SampleModel> sampleList = [];
  SampleModel? selectedSample;

  bool loading = false;

  /// โหลดรายการ sample (ไม่มี lab)
  Future<void> loadSamples() async {
    loading = true;
    notifyListeners();

    try {
      final data = await SampleService.fetchAllSamplesRaw();

      if (data != null) {
        sampleList = data
            .map<SampleModel>((e) => SampleModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error loading samples: $e");
      sampleList = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// โหลด sample รายตัว (มี lab)
  Future<void> loadSampleDetail(String sampName) async {
  loading = true;
  notifyListeners();

  try {
    // ✅ ใช้ raw json
    final data = await SampleService.fetchSampleByNameRaw(sampName);

    if (data != null) {
      selectedSample = SampleModel.fromJson(data);

      debugPrint("===== SAMPLE DEBUG =====");
      debugPrint(selectedSample.toString());
      debugPrint(selectedSample?.lab.toString());
    } else {
      selectedSample = null;
    }
  } catch (e) {
    debugPrint("Error fetching sample detail: $e");
    selectedSample = null;
  } finally {
    loading = false;
    notifyListeners();
  }
}

}
