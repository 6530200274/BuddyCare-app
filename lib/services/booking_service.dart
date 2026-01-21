import 'package:cloud_firestore/cloud_firestore.dart';

class BookingFirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveSelection({
    required String userId,
    required DateTime serviceDate,
    required String serviceTime,
  }) async {
    // ตัวอย่างเก็บเป็น draft (ยังไม่ยืนยัน)
    await _db.collection('bookingDrafts').doc(userId).set({
      'serviceDate': Timestamp.fromDate(serviceDate),
      'serviceTime': serviceTime,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
