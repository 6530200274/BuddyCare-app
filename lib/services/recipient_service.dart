import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipient_profile.dart';

class RecipientService {
  RecipientService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.collection('users').doc(uid).collection('recipient').doc('profile');
  }

  Future<RecipientProfile?> getProfile(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists) return null;

    final data = snap.data()!;
    return RecipientProfile(
      firstName: (data['firstName'] ?? '') as String,
      lastName: (data['lastName'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      dob: (data['dob'] as Timestamp?)?.toDate(),
      nationality: (data['nationality'] ?? '') as String,
      religion: (data['religion'] ?? '') as String,
      language: (data['language'] ?? '') as String,
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      gender: (data['gender'] ?? '') as String,
      relationship: (data['relationship'] ?? '') as String,
      emergencyContact: EmergencyContact.fromMap(
        (data['emergencyContact'] as Map?)?.cast<String, dynamic>(),
      ),
    );
  }

  Future<void> upsertProfile({
    required String uid,
    required RecipientProfile profile,
  }) async {
    await _doc(uid).set(
      {
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
