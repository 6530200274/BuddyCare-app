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

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<List<_RankedCaregiver>> _loadAllSorted({
    required BookingProvider bookingP,
    required MeetingPointProvider meetingP,
    required ADLProvider adlP,
  }) async {
    final meeting = meetingP.data;

    final provinceNeed = meeting?.province.trim() ?? '';
    final districtIdNeed = meeting?.districtId.trim() ?? '';
    final subdistrictIdNeed = meeting?.subdistrictId.trim() ?? '';
    final districtNeedName = meeting?.districtName.trim() ?? '';
    final subdistrictNeedName = meeting?.subdistrictName.trim() ?? '';

    final date = bookingP.data.serviceDate;
    final timeNeedRaw = bookingP.data.serviceTime
        ?.trim(); // "06:00" หรือ "0600"

    if (date == null) return [];

    final dateKey = _dateKey(date);
    final timeNeed = (timeNeedRaw == null)
        ? ''
        : timeNeedRaw.replaceAll(':', '');

    final caregiverTypeNeed = adlP.result?.caregiverType;
    final roleNeed =
        (caregiverTypeNeed == null || caregiverTypeNeed.trim().isEmpty)
        ? null
        : _service.mapCaregiverTypeToRole(caregiverTypeNeed);

    final snap = await FirebaseFirestore.instance
        .collection('caregiver_slots')
        .where('dateKey', isEqualTo: dateKey)
        .where('isAvailable', isEqualTo: true)
        .get();

    if (snap.docs.isEmpty) return [];

    final ranked = snap.docs
        .map((d) {
          final m = d.data();

          final firstName = (m['firstName'] ?? '').toString();
          final lastName = (m['lastName'] ?? '').toString();

          final caregiverTypeFromDb = (m['caregiverType'] ?? '').toString();
          final roleFromDb = caregiverTypeFromDb.isEmpty
              ? ''
              : (_service.mapCaregiverTypeToRole(caregiverTypeFromDb) ??
                    caregiverTypeFromDb);

          final province = (m['province'] ?? '').toString().trim();

          // ใช้ id เป็นหลัก
          final districtId = (m['districtId'] ?? '').toString().trim();
          final subdistrictId = (m['subdistrictId'] ?? '').toString().trim();

          // ชื่อจาก slot (ใช้ตอน id ซ้ำ/ว่าง)
          final districtName = (m['district'] ?? '').toString().trim();
          final subdistrictName = (m['subdistrict'] ?? '').toString().trim();

          final slotId = (m['slotId'] ?? '').toString(); // "2026-01-30_0600"
          final slotTime = slotId.contains('_') ? slotId.split('_').last : '';

          // ---------- matching ชั้น ๆ ----------
          final okProvince = provinceNeed.isEmpty || province == provinceNeed;

          // districtId ตรงหรือไม่
          final okDistrictId =
              districtIdNeed.isEmpty || districtId == districtIdNeed;

          // subdistrictId ตรงหรือไม่
          final okSubdistrictId =
              subdistrictIdNeed.isEmpty || subdistrictId == subdistrictIdNeed;

          // fallback ชื่อ: ใช้ก็ต่อเมื่อ "id ว่าง" หรือ "dataset ซ้ำ id แล้วชื่อช่วยแยก"
          final needNameFallbackDistrict =
              districtIdNeed.isEmpty ||
              districtId.isEmpty ||
              (districtIdNeed.isNotEmpty && districtId == districtIdNeed);

          final needNameFallbackSubdistrict =
              subdistrictIdNeed.isEmpty ||
              subdistrictId.isEmpty ||
              (subdistrictIdNeed.isNotEmpty &&
                  subdistrictId == subdistrictIdNeed);

          final okDistrictName = !needNameFallbackDistrict
              ? true
              : (districtNeedName.isEmpty || districtName == districtNeedName);

          final okSubdistrictName = !needNameFallbackSubdistrict
              ? true
              : (subdistrictNeedName.isEmpty ||
                    subdistrictName == subdistrictNeedName);

          // เวลา: ให้คะแนนถ้าตรง แต่ไม่ตัดทิ้ง
          final okTime = timeNeed.isEmpty ? true : (slotTime == timeNeed);

          // role: ให้คะแนนถ้าตรง แต่ไม่ตัดทิ้ง
          final okRole = (roleNeed == null || roleNeed.trim().isEmpty)
              ? true
              : roleFromDb.trim() == roleNeed.trim();

          // ---------- scoring ตาม priority ที่ต้องการ ----------
          int score = 0;

          // วันตรงอยู่แล้ว
          score += 50;

          // จังหวัด
          if (okProvince) score += 30;

          // เขต: id ตรงสำคัญสุด
          if (okDistrictId) score += 40;

          // แขวง: ถ้าเขตตรง แล้วแขวง id ตรง -> ดันขึ้นอันดับแรก
          if (okDistrictId && okSubdistrictId) score += 60;

          // ถ้า id ซ้ำ/ว่าง ให้ใช้ชื่อช่วยดัน (เพิ่มคะแนนเล็กน้อย)
          if (okDistrictId && okDistrictName) score += 5;
          if (okDistrictId && okSubdistrictId && okSubdistrictName) score += 10;

          // เวลา
          if (okTime) score += 20;

          // ประเภทผู้ดูแล
          if (okRole) score += 10;

          // isMatched = ตรงครบชุดที่ดีที่สุด (เขต+แขวง+เวลา+role+จังหวัด)
          final isMatched =
              okProvince && okDistrictId && okSubdistrictId && okTime && okRole;

          final c = Caregiver(
            id: d.id,
            name: firstName,
            lastName: lastName,
            role: roleFromDb,
            province: province,
            district: districtName,
            subdistrict: subdistrictName,
            rating: (m['rating'] is num)
                ? (m['rating'] as num).toDouble()
                : 5.0,
            photoUrl: m['photoUrl']?.toString(),
            isMatched: isMatched,
            matchScore: score,
            districtId: districtId,
            subdistrictId: subdistrictId,
          );

          return _RankedCaregiver(
            caregiver: c,
            isMatched: isMatched,
            matchScore: score,
          );
        })
        // “ไม่อยากให้ต่างจังหวัดโผล่เลย”
        .where(
          (x) =>
              provinceNeed.isEmpty ||
              x.caregiver.province.trim() == provinceNeed,
        )
        .toList();

    // เรียง: (1) เขต+แขวงตรง id ก่อน (2) เขตตรงก่อน (3) isMatched (4) score (5) rating
    ranked.sort((a, b) {
      final aExactArea =
          a.caregiver.districtId.trim() == districtIdNeed &&
          a.caregiver.subdistrictId.trim() == subdistrictIdNeed;
      final bExactArea =
          b.caregiver.districtId.trim() == districtIdNeed &&
          b.caregiver.subdistrictId.trim() == subdistrictIdNeed;
      if (aExactArea != bExactArea) return aExactArea ? -1 : 1;

      final aDistrictOnly = a.caregiver.districtId.trim() == districtIdNeed;
      final bDistrictOnly = b.caregiver.districtId.trim() == districtIdNeed;
      if (aDistrictOnly != bDistrictOnly) return aDistrictOnly ? -1 : 1;

      if (a.isMatched != b.isMatched) return a.isMatched ? -1 : 1;

      final s = b.matchScore.compareTo(a.matchScore);
      if (s != 0) return s;

      return b.caregiver.rating.compareTo(a.caregiver.rating);
    });

    return ranked;
  }

  @override
  Widget build(BuildContext context) {
    final bookingP = context.watch<BookingProvider>();
    final meetingP = context.watch<MeetingPointProvider>();
    final adlP = context.watch<ADLProvider>();

    final date = bookingP.data.serviceDate;
    final time = (bookingP.data.serviceTime ?? '').trim();

    // key ผูกกับวันที่+เวลา เพื่อบังคับ FutureBuilder รีเฟรชเมื่อเปลี่ยน
    final futureKey =
        '${date != null ? _dateKey(date) : 'no-date'}_${time.replaceAll(':', '')}';

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
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
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
          key: ValueKey(futureKey), // ตรงนี้สำคัญ
          future: _loadAllSorted(
            bookingP: bookingP,
            meetingP: meetingP,
            adlP: adlP,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Center(
                child: Text(
                  'เกิดข้อผิดพลาด: ${snap.error}',
                  textAlign: TextAlign.center,
                ),
              );
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
              separatorBuilder: (_, _) => const SizedBox(height: 14),
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
