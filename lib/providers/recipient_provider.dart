import 'package:flutter/foundation.dart';
import '../models/recipient_profile.dart';

class RecipientProvider extends ChangeNotifier {
  RecipientProfile? _profile;

  RecipientProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  void setProfile(RecipientProfile p) {
    _profile = p;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
