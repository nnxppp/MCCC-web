// sample.dart
import 'dart:convert';
import 'package:example/models/labSample.dart';

/// =======================
/// Simple Sample (สำหรับ list / search / preview)
/// =======================
class Sample {
  final String id;
  final String sampName;
  final String sampTitle;
  final DateTime? collectionDate;
  final String collectedBy;
  final String collectedByName;
  final String? pictureUrl;
  final String? organism;
  final String? bioprojectId;

  // keep raw nested objects so UI/search can use them
  final Map<String, dynamic>? sampleInfo;
  final Map<String, dynamic>? environmentInfo;

  Sample({
    required this.id,
    required this.sampName,
    required this.sampTitle,
    this.collectionDate,
    required this.collectedBy,
    required this.collectedByName,
    this.pictureUrl,
    this.organism,
    this.bioprojectId,
    this.sampleInfo,
    this.environmentInfo,
  });

  factory Sample.fromJson(Map<String, dynamic> json) {
    // support both snake_case and camelCase
    final sampleInfo = (json['sample_info'] as Map<String, dynamic>?) ??
        (json['sampleInfo'] as Map<String, dynamic>?);

    final environmentInfo =
        (json['environment_info'] as Map<String, dynamic>?) ??
            (json['environmentInfo'] as Map<String, dynamic>?);

    // collection date
    DateTime? collectionDate;
    try {
      final col =
          sampleInfo?['collection_date'] ?? sampleInfo?['collectionDate'];
      if (col != null) collectionDate = DateTime.parse(col.toString());
    } catch (_) {}

    // first picture if exists
    String? pictureUrl;
    try {
      final pics = sampleInfo?['picture'] as List<dynamic>?;
      if (pics != null && pics.isNotEmpty) {
        pictureUrl = pics.first?.toString();
      }
    } catch (_) {}

    // organism
    final organism = sampleInfo?['organism']?.toString() ??
        sampleInfo?['Organism']?.toString() ??
        json['organism']?.toString();

    // samp title
    final sampTitle = sampleInfo?['samp_title']?.toString() ??
        sampleInfo?['sampTitle']?.toString() ??
        '';

    // samp name
    final sampName = json['samp_name']?.toString() ??
        json['sampName']?.toString() ??
        '';

    // collected_by
    String collectedBy = '';
    String collectedByName = '';
    try {
      final cb = json['collected_by'];
      if (cb is Map) {
        collectedBy = cb['_id']?.toString() ?? cb['id']?.toString() ?? '';
        collectedByName = cb['name']?.toString() ?? '';
      } else if (cb != null) {
        collectedBy = cb.toString();
      }

      collectedByName = collectedByName.isNotEmpty
          ? collectedByName
          : (json['collected_by_name']?.toString() ??
              json['collectedByName']?.toString() ??
              '');
    } catch (_) {}

    // bioproject id
    final bioprojectId = sampleInfo?['bioproject_id']?.toString() ??
        sampleInfo?['bioprojectId']?.toString() ??
        json['bioproject_id']?.toString() ??
        json['bioprojectId']?.toString();

    return Sample(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      sampName: sampName,
      sampTitle: sampTitle,
      collectionDate: collectionDate,
      collectedBy: collectedBy,
      collectedByName: collectedByName,
      pictureUrl: pictureUrl,
      organism: organism,
      bioprojectId: bioprojectId,
      sampleInfo: sampleInfo,
      environmentInfo: environmentInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'samp_name': sampName,
      'sample_info': sampleInfo,
      'environment_info': environmentInfo,
      'collected_by': collectedBy,
      'collected_by_name': collectedByName,
    };
  }
}

/// =======================
/// Full Sample Model (detail page)
/// =======================
class SampleModel {
  // Sample Info
  final String id;
  final String? sampName;
  final String? sampTitle;
  final String? description;
  final String? organism;
  final String? envMedium;
  final String? collectMeth;
  final String? depth;
  final String? isolSource;
  final String? sampCollectDevice;
  final String? sampSize;
  final String? bioprojectId;
  final DateTime? collectionDate;
  final List<String>? pictures;

  // Environment Info
  final List<double>? geoLatlon;
  final double? alt;
  final String? addressSubdistrict;
  final String? addressDistrict;
  final String? addressProvince;
  final double? temp;
  final double? humidity;
  final double? precpt;
  final double? annualTemp;
  final double? annualPrecpt;
  final String? slopeAspect;
  final double? slopeGradient;
  final String? soilHorizon;

  // Area History
  final String? agrochemAddition;
  final String? cropRotation;
  final String? curLandUse;
  final String? curVegetation;
  final String? curVegetationMeth;
  final String? drainageClass;
  final String? extremeEvent;
  final String? fire;
  final String? flooding;
  final String? previousLandUse;
  final String? previousLandUseMeth;

  // Collected By
  final String? collectedById;
  final String? collectedByName;

  // Lab
  final LabSample? lab;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SampleModel({
    required this.id,
    this.sampName,
    this.sampTitle,
    this.description,
    this.organism,
    this.envMedium,
    this.collectMeth,
    this.depth,
    this.isolSource,
    this.sampCollectDevice,
    this.sampSize,
    this.bioprojectId,
    this.collectionDate,
    this.pictures,
    this.geoLatlon,
    this.alt,
    this.addressSubdistrict,
    this.addressDistrict,
    this.addressProvince,
    this.temp,
    this.humidity,
    this.precpt,
    this.annualTemp,
    this.annualPrecpt,
    this.slopeAspect,
    this.slopeGradient,
    this.soilHorizon,
    this.agrochemAddition,
    this.cropRotation,
    this.curLandUse,
    this.curVegetation,
    this.curVegetationMeth,
    this.drainageClass,
    this.extremeEvent,
    this.fire,
    this.flooding,
    this.previousLandUse,
    this.previousLandUseMeth,
    this.collectedById,
    this.collectedByName,
    this.lab,
    this.createdAt,
    this.updatedAt,
  });

  factory SampleModel.fromJson(Map<String, dynamic> json) {
    final sampleInfo = json['sample_info'] ?? {};
    final envInfo = json['environment_info'] ?? {};
    final address = envInfo['address'] ?? {};
    final climate = envInfo['climate_info'] ?? {};
    final areaHistory = json['area_history'] ?? {};
    final collectedBy = json['collected_by'] ?? {};

    return SampleModel(
      id: json['_id'] ?? '',
      sampName: sampleInfo['samp_name'],
      sampTitle: sampleInfo['samp_title'],
      description: sampleInfo['desc_samp'],
      organism: sampleInfo['organism'],
      envMedium: sampleInfo['env_medium'],
      collectMeth: sampleInfo['collect_meth'],
      depth: sampleInfo['depth']?.toString(),
      isolSource: sampleInfo['isol_source'],
      sampCollectDevice: sampleInfo['samp_collect_device'],
      sampSize: sampleInfo['samp_size']?.toString(),
      bioprojectId: sampleInfo['bioproject_id'],
      collectionDate: sampleInfo['collection_date'] != null
          ? DateTime.tryParse(sampleInfo['collection_date'])
          : null,
      pictures: sampleInfo['picture'] != null
          ? List<String>.from(
              sampleInfo['picture'].map((e) => e.toString()),
            )
          : [],

      // Environment Info
      geoLatlon: envInfo['geo_latlon'] != null
          ? List<double>.from(
              envInfo['geo_latlon'].map((e) => e.toDouble()),
            )
          : null,
      alt: envInfo['alt']?.toDouble(),
      addressSubdistrict: address['subdistrict'],
      addressDistrict: address['district'],
      addressProvince: address['province'],
      temp: climate['temp']?.toDouble(),
      humidity: climate['humidity']?.toDouble(),
      precpt: climate['precpt']?.toDouble(),
      annualTemp: envInfo['annual_temp']?.toDouble(),
      annualPrecpt: envInfo['annual_precpt']?.toDouble(),
      slopeAspect: envInfo['slope_aspect'],
      slopeGradient: envInfo['slope_gradient']?.toDouble(),
      soilHorizon: envInfo['soil_horizon'],

      // Area History
      agrochemAddition: areaHistory['agrochem_addition'],
      cropRotation: areaHistory['crop_rotation'],
      curLandUse: areaHistory['cur_land_use'],
      curVegetation: areaHistory['cur_vegetation'],
      curVegetationMeth: areaHistory['cur_vegetation_meth'],
      drainageClass: areaHistory['drainage_class'],
      extremeEvent: areaHistory['extreme_event'],
      fire: areaHistory['fire'],
      flooding: areaHistory['flooding'],
      previousLandUse: areaHistory['previous_land_use'],
      previousLandUseMeth: areaHistory['previous_land_use_meth'],

      // Collected By
      collectedById: collectedBy['_id'],
      collectedByName: collectedBy['name'],

      // Lab
      lab: json['lab_results'] != null
          ? LabSample.fromJson(json['lab_results'])
          : null,

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}
