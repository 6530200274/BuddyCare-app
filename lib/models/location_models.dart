class Hospital {
  final String id;
  final String name;
  Hospital({required this.id, required this.name});

  factory Hospital.fromJson(Map<String, dynamic> j) =>
      Hospital(id: j['id'], name: j['name']);
}

class ProvinceHospitals {
  final String provinceCode;
  final String provinceName;
  final List<Hospital> hospitals;

  ProvinceHospitals({
    required this.provinceCode,
    required this.provinceName,
    required this.hospitals,
  });

  factory ProvinceHospitals.fromJson(Map<String, dynamic> j) {
    return ProvinceHospitals(
      provinceCode: j['province_code'],
      provinceName: j['province'],
      hospitals: (j['hospitals'] as List<dynamic>)
          .map((e) => Hospital.fromJson(e))
          .toList(),
    );
  }
}

class District {
  final String id;
  final String nameTh;
  District({required this.id, required this.nameTh});

  factory District.fromJson(Map<String, dynamic> j) =>
      District(id: j['id'], nameTh: j['name_th']);
}

class Subdistrict {
  final String id;
  final String districtId;
  final String nameTh;

  Subdistrict({required this.id, required this.districtId, required this.nameTh});

  factory Subdistrict.fromJson(Map<String, dynamic> j) => Subdistrict(
        id: j['id'],
        districtId: j['district_id'],
        nameTh: j['name_th'],
      );
}
