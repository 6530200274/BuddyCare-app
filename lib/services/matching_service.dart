import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Caregiver {
  final String id;
  final String name;
  final String? lastName;
  final String role; // "พยาบาลวิชาชีพ" / "ผู้ช่วยพยาบาล" / "ผู้ดูแล"
  final String province;
  final String district;
  final String subdistrict;
  final double rating;
  final String? photoUrl;
  final bool isMatched;
  final int matchScore;

  Caregiver({
    required this.id,
    required this.name,
    required this.lastName,
    required this.role,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.rating,
    required this.photoUrl,
    required this.isMatched,
    required this.matchScore,
  });

  factory Caregiver.fromMap(String id, Map<String, dynamic> m) {
    return Caregiver(
      id: id,
      name: (m['name'] ?? '').toString(),
      lastName: m['latName']?.toString(),
      role: (m['role'] ?? '').toString(),
      province: (m['province'] ?? '').toString(),
      district: (m['district'] ?? '').toString(),
      subdistrict: (m['subdistrict'] ?? '').toString(),
      rating: (m['rating'] is num) ? (m['rating'] as num).toDouble() : 5.0,
      photoUrl: m['photoUrl']?.toString(),
      isMatched: m['isMatched'] ?? false,
      matchScore: m['matchScore'] ?? 0,
    );
  }

  String get fullName {
    final ln = (lastName ?? '').trim();
    return ln.isEmpty ? name : '$name $ln';
  }

  String get roleLabel {
    switch (role) {
      case 'พยาบาลวิชาชีพ':
        return 'พยาบาลวิชาชีพ (Registered Nurse: RN)';
      case 'ผู้ช่วยพยาบาล':
        return 'ผู้ช่วยพยาบาล (Practical Nurse: PN)';
      default:
        return 'ผู้ดูแล (NA/Caregiver)';
    }
  }
}

class CaregiverMatchService {
  final FirebaseFirestore _db;
  CaregiverMatchService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// caregiverType -> role ที่เก็บใน Firestore
  /// ปรับ mapping ให้ตรงกับคำที่คุณใช้จริงได้
  String? mapCaregiverTypeToRole(String caregiverType) {
    final t = caregiverType.trim().toLowerCase();

    // ตัวอย่างรองรับหลายรูปแบบ
    if (t.contains('rn') || t.contains('registered') || t.contains('พยาบาลวิชาชีพ')) {
      return 'พยาบาลวิชาชีพ';
    }
    if (t.contains('pn') || t.contains('practical') || t.contains('ผู้ช่วยพยาบาล')) {
      return 'ผู้ช่วยพยาบาล';
    }
    if (t.contains('na') || t.contains('caregiver') || t.contains('ผู้ดูแล')) {
      return 'ผู้ดูแล';
    }
    return null; // ถ้าไม่รู้ให้ไม่กรอง role
  }

  Future<List<Caregiver>> matchCaregivers({
    required String province,
    required String districtName,
    String? subdistrictName,
    required DateTime serviceDate,
    required String serviceTime,
    String? caregiverType, // จาก ADLProvider (optional)
  }) async {
    final dateStr = _dateKey(serviceDate);
    final roleFilter = (caregiverType == null || caregiverType.trim().isEmpty)
        ? null
        : mapCaregiverTypeToRole(caregiverType);

    // 1) หา slot ว่างจากทุก roles/*/time/*
    final timeSnap = await _db
        .collectionGroup('time')
        .where('date', isEqualTo: dateStr)
        .where('time', isEqualTo: serviceTime)
        .get();

    if (timeSnap.docs.isEmpty) return [];

    // 2) หา parent roles/{caregiverId}
    final refs = <DocumentReference>[];
    for (final t in timeSnap.docs) {
      final parent = t.reference.parent.parent; // roles/{id}
      if (parent != null) refs.add(parent);
    }

    final uniqueRefs = {for (final r in refs) r.path: r}.values.toList();

    // 3) ดึง role docs แล้ว filter พื้นที่ + role
    final snaps = await Future.wait(uniqueRefs.map((r) => r.get()));

    final out = <Caregiver>[];
    for (final doc in snaps) {
      if (!doc.exists) continue;

      final c = Caregiver.fromMap(doc.id, doc.data() as Map<String, dynamic>);

      if (c.province != province) continue;
      if (c.district != districtName) continue;

      if (subdistrictName != null && subdistrictName.trim().isNotEmpty) {
        if (c.subdistrict != subdistrictName) continue;
      }

      if (roleFilter != null && c.role != roleFilter) continue;

      out.add(c);
    }

    out.sort((a, b) => b.rating.compareTo(a.rating));
    return out;
  }
}