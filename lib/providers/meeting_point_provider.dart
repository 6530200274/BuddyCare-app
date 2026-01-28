import 'package:flutter/foundation.dart';

class MeetingPointData {
  final String address;
  final String province;
  final String districtId;
  final String districtName;
  final String subdistrictId;
  final String subdistrictName;
  final String postcode;

  final String destProvince;
  final String hospitalId;
  final String hospitalName;

  const MeetingPointData({
    required this.address,
    required this.province,
    required this.districtId,
    required this.districtName,
    required this.subdistrictId,
    required this.subdistrictName,
    required this.postcode,
    required this.destProvince,
    required this.hospitalId,
    required this.hospitalName,
  });
}

class MeetingPointProvider extends ChangeNotifier {
  MeetingPointData? _data;

  MeetingPointData? get data => _data;
  bool get hasData => _data != null;

  void setData(MeetingPointData d) {
    _data = d;
    notifyListeners();
  }

  void clear() {
    _data = null;
    notifyListeners();
  }
}
