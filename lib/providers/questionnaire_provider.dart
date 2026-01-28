import 'package:flutter/foundation.dart';

class ADLResult {
  final List<int> scores; // 10 ข้อ
  final int totalScore; // รวม
  final String caregiverType; // ผลแมทช์

  const ADLResult({
    required this.scores,
    required this.totalScore,
    required this.caregiverType,
  });
}

class ADLProvider extends ChangeNotifier {
  ADLResult? _result;

  ADLResult? get result => _result;
  bool get hasResult => _result != null;

  void setResult(ADLResult r) {
    _result = r;
    notifyListeners();
  }

  void clear() {
    _result = null;
    notifyListeners();
  }
}
