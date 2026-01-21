import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BkkDistrict {
  final String id;
  final String nameTh;
  final String nameEn;

  BkkDistrict({
    required this.id,
    required this.nameTh,
    required this.nameEn,
  });

  factory BkkDistrict.fromJson(Map<String, dynamic> json) {
    return BkkDistrict(
      id: json['id'] as String,
      nameTh: json['name_th'] as String,
      nameEn: (json['name_en'] ?? '') as String,
    );
  }
}

class BkkSubdistrict {
  final String id;
  final String districtId;
  final String nameTh;
  final String nameEn;

  BkkSubdistrict({
    required this.id,
    required this.districtId,
    required this.nameTh,
    required this.nameEn,
  });

  factory BkkSubdistrict.fromJson(Map<String, dynamic> json) {
    return BkkSubdistrict(
      id: json['id'] as String,
      districtId: json['district_id'] as String,
      nameTh: json['name_th'] as String,
      nameEn: (json['name_en'] ?? '') as String,
    );
  }
}

class BkkMasterData {
  final List<BkkDistrict> districts;
  final List<BkkSubdistrict> subdistricts;

  /// index เอาไว้ join เร็ว ๆ: districtId -> list แขวง
  final Map<String, List<BkkSubdistrict>> subdistrictsByDistrictId;

  BkkMasterData({
    required this.districts,
    required this.subdistricts,
    required this.subdistrictsByDistrictId,
  });
}

Future<BkkMasterData> loadBkkMasterData() async {
  final raw = await rootBundle.loadString('assets/bkk_master_district_subdistrict.json');
  final Map<String, dynamic> decoded = json.decode(raw);

  final districtsJson = List<Map<String, dynamic>>.from(decoded['districts'] as List);
  final subdistrictsJson = List<Map<String, dynamic>>.from(decoded['subdistricts'] as List);

  final districts = districtsJson.map(BkkDistrict.fromJson).toList()
    ..sort((a, b) => a.nameTh.compareTo(b.nameTh));

  final subdistricts = subdistrictsJson.map(BkkSubdistrict.fromJson).toList()
    ..sort((a, b) => a.nameTh.compareTo(b.nameTh));

  final Map<String, List<BkkSubdistrict>> byDistrict = {};
  for (final s in subdistricts) {
    byDistrict.putIfAbsent(s.districtId, () => <BkkSubdistrict>[]).add(s);
  }

  // sort list ของแต่ละเขต
  for (final e in byDistrict.entries) {
    e.value.sort((a, b) => a.nameTh.compareTo(b.nameTh));
  }

  return BkkMasterData(
    districts: districts,
    subdistricts: subdistricts,
    subdistrictsByDistrictId: byDistrict,
  );
}
