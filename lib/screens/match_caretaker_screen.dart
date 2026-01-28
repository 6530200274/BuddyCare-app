import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../providers/booking_provider.dart';
import '../providers/meeting_point_provider.dart';
import 'package:my_app/providers/questionnaire_provider.dart';
import 'package:my_app/services/matching_service.dart';

class MatchCaregiverScreen extends StatefulWidget {
  const MatchCaregiverScreen({super.key});

  @override
  State<MatchCaregiverScreen> createState() => _MatchCaregiverScreenState();
}

class _RankedCaregiver {
  final Caregiver caregiver;
  final bool isMatched;
  final int matchScore;

  const _RankedCaregiver({
    required this.caregiver,
    required this.isMatched,
    required this.matchScore,
  });
}

class _MatchCaregiverScreenState extends State<MatchCaregiverScreen> {
  final _service = CaregiverMatchService(db: FirebaseFirestore.instance);

  String _norm(String s) => s.trim();
  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<List<_RankedCaregiver>> _loadAllSorted({
    required BookingProvider bookingP,
    required MeetingPointProvider meetingP,
    required ADLProvider adlP,
  }) async {
    final meeting = meetingP.data;

    // แสดงทั้งหมดได้
    final String province = meeting?.province.trim() ?? '';
    final String districtName = meeting?.districtName.trim() ?? '';
    final String subdistrictName = meeting?.subdistrictName.trim() ?? '';

    final DateTime? date = bookingP.data.serviceDate;
    final String? time = bookingP.data.serviceTime;

    final String? caregiverType = adlP.result?.caregiverType;

    // ถ้า service ไม่มี mapCaregiverTypeToRole ก็ไม่กรอง role (ให้ผ่าน)
    String? roleNeed;
    try {
      roleNeed = (caregiverType == null || caregiverType.trim().isEmpty)
          ? null
          : _service.mapCaregiverTypeToRole(caregiverType);
    } catch (_) {
      roleNeed = null;
    }

    // 1) ดึง roles ทั้งหมด
    final rolesSnap = await FirebaseFirestore.instance
        .collection('roles')
        .get();
    final all = rolesSnap.docs
        .map((d) => Caregiver.fromMap(d.id, d.data()))
        .toList();

    // 2) หา caregiverIds ที่ "ว่าง" ตามวัน+เวลา (ถ้ามี)
    final Set<String> availableIds = {};
    if (date != null && time != null && time.trim().isNotEmpty) {
      final tSnap = await FirebaseFirestore.instance
          .collectionGroup('time')
          .where('date', isEqualTo: _dateKey(date))
          .where('time', isEqualTo: time.trim())
          .get();

      for (final doc in tSnap.docs) {
        final parent = doc.reference.parent.parent; // roles/{id}
        if (parent != null) availableIds.add(parent.id);
      }
    }

    // 3) คำนวณคะแนน + matched
    // คะแนน: ว่างเวลา(50) + จังหวัด(15) + เขต(15) + แขวง(10) + role(10)
    final ranked = all.map((c) {
      int score = 0;

      final bool okTime = availableIds.contains(c.id);
      if (okTime) score += 50;

      final bool okProvince = province.isEmpty || _norm(c.province) == province;
      final bool okDistrict =
          districtName.isEmpty || _norm(c.district) == districtName;
      final bool okSub =
          subdistrictName.isEmpty || _norm(c.subdistrict) == subdistrictName;

      if (province.isNotEmpty && okProvince) score += 15;
      if (districtName.isNotEmpty && okDistrict) score += 15;
      if (subdistrictName.isNotEmpty && okSub) score += 10;

      final bool okRole = (roleNeed == null) ? true : (c.role == roleNeed);
      if (roleNeed != null && okRole) score += 10;

      final bool isMatched =
          okTime && okProvince && okDistrict && okSub && okRole;

      return _RankedCaregiver(
        caregiver: c,
        isMatched: isMatched,
        matchScore: score,
      );
    }).toList();

    // 4) sort: matched ก่อน -> score มากก่อน -> rating มากก่อน
    ranked.sort((a, b) {
      if (a.isMatched != b.isMatched) return a.isMatched ? -1 : 1;

      final s = b.matchScore.compareTo(a.matchScore);
      if (s != 0) return s;

      // rating ของ Caregiver ของคุณเป็น double อยู่แล้ว
      return b.caregiver.rating.compareTo(a.caregiver.rating);
    });

    return ranked;
  }

  @override
  Widget build(BuildContext context) {
    final bookingP = context.watch<BookingProvider>();
    final meetingP = context.watch<MeetingPointProvider>();
    final adlP = context.watch<ADLProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFFFA726),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "เลือกผู้ดูแล",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                minimumSize: const Size(0, 40), 
                padding: const EdgeInsets.symmetric(
                  horizontal: 18, 
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22), 
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "ยกเลิก",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<_RankedCaregiver>>(
          future: _loadAllSorted(
            bookingP: bookingP,
            meetingP: meetingP,
            adlP: adlP,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snap.data ?? [];

            if (items.isEmpty) {
              return const Center(
                child: Text(
                  "ยังไม่มีผู้ดูแลในระบบ",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _CaregiverCard(
                caregiver: items[i].caregiver,
                isMatched: items[i].isMatched,
                onProfile: () {},
                onBook: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CaregiverCard extends StatelessWidget {
  final Caregiver caregiver;
  final bool isMatched;
  final VoidCallback onProfile;
  final VoidCallback onBook;

  const _CaregiverCard({
    required this.caregiver,
    required this.isMatched,
    required this.onProfile,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF6701);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatched ? orange : const Color(0xFFFFD4B8),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _Avatar(photoUrl: caregiver.photoUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        caregiver.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 18, color: Color(0xFFFFB300)),
                    const SizedBox(width: 4),
                    Text(
                      caregiver.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                if (isMatched) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "ตรงตามเงื่อนไข",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  caregiver.roleLabel,
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onProfile,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: orange, width: 1.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          "ดูโปรไฟล์",
                          style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        child: const Text(
                          "จองคิว",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  const _Avatar({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFD4B8), width: 1.2),
        color: const Color(0xFFF5F5F5),
        image: (photoUrl != null && photoUrl!.trim().isNotEmpty)
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: (photoUrl == null || photoUrl!.trim().isEmpty)
          ? const Icon(Icons.person, size: 34, color: Color(0xFFBDBDBD))
          : null,
    );
  }
}
