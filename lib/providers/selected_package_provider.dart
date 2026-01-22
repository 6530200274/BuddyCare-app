import 'package:flutter/foundation.dart';
import '../models/package_model.dart';

class SelectedPackageProvider extends ChangeNotifier {
  CarePackage? _selected;

  // ใช้ตัวนี้ใน UI
  CarePackage? get selected => _selected;

  // เรียกตอนเลือกแพ็กเกจ
  void select(CarePackage pkg) {
    _selected = pkg;
    notifyListeners();
  }

  void clear() {
    _selected = null;
    notifyListeners();
  }
}
