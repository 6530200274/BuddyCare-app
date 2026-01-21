import 'package:flutter/foundation.dart';
import '../models/booking_selection.dart';

class BookingProvider extends ChangeNotifier {
  BookingSelection _data = const BookingSelection();

  BookingSelection get data => _data;

  void setServiceDate(DateTime d) {
    _data = _data.copyWith(serviceDate: DateTime(d.year, d.month, d.day), address: '', postcode: '');
    notifyListeners();
  }

  void setServiceTime(String t) {
    _data = _data.copyWith(serviceTime: t, address: '', postcode: '');
    notifyListeners();
  }

  void clear() {
    _data = const BookingSelection();
    notifyListeners();
  }
} 