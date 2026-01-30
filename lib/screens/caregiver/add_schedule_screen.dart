import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/screens/caregiver/home_schedule_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final firstDate = DateTime(2026, 1);
  final lastDate = DateTime(2030, 12);

  String selectedStatus = 'ว่างงาน';

  bool _saving = false;

  String _formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String _timeKey(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const yellow = Color(0xFFFEA82F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: yellow,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _saving ? null : () => Navigator.pop(context),
              child: const Center(
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          "เพิ่มตารางงาน",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // -------- ปฏิทิน --------
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: (newDate) {
                setState(() => selectedDate = newDate);
              },
            ),

            // -------- ฟอร์มเลือกวันที่ --------
            const Text(
              "วันที่ให้บริการ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w100,
                color: Color(0xFF737373),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _saving ? null : () => _openDatePicker(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4D4D4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      DateFormat('d MMMM y', 'th_TH').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // -------- ฟอร์มเลือกเวลา --------
            const Text(
              "เวลาที่ให้บริการ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w100,
                color: Color(0xFF737373),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _saving ? null : () => _openTimePicker(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4D4D4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Text(
                      _formatTime24(selectedTime),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: Color(0xFF737373),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // -------- ฟอร์มเลือกสถานะ --------
            const Text(
              "สถานะตารางงาน",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w100,
                color: Color(0xFF737373),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4D4D4), width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Color(0xFF737373),
                  ),
                  isExpanded: true,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ว่างงาน', child: Text('ว่างงาน')),
                    DropdownMenuItem(value: 'มีงาน', child: Text('มีงาน')),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => selectedStatus = value);
                        },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // -------- ปุ่มบันทึก --------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'บันทึก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _openTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _onSave() async {
    // รวมวันที่+เวลา เป็น DateTime เดียว (local)
    final DateTime serviceDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเข้าสู่ระบบใหม่')));
      return;
    }

    final dk = _dateKey(selectedDate);
    final tk = _timeKey(selectedTime);
    final slotId = '${dk}_$tk'; // เช่น 2026-01-29_1300

    setState(() => _saving = true);

    try {
      // 1) ดึงข้อมูล caregiver เพื่อเอา address + ids + caregiverType + name
      final caregiverSnap = await FirebaseFirestore.instance
          .collection('caregiver')
          .doc(uid)
          .get();

      final caregiver = caregiverSnap.data() ?? {};

      // (A) caregiverType
      // รองรับทั้งรูปแบบ: caregiver['caregiverType'] หรือ caregiver['career']['caregiverType']
      final career = (caregiver['career'] is Map)
          ? (caregiver['career'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      final caregiverType =
          (caregiver['caregiverType'] ?? career['caregiverType'])?.toString();

      // (B) address + ids
      // รองรับ: caregiver['address'] หรือ field อยู่ root เช่น districtId/subdistrictId
      final address = (caregiver['address'] is Map)
          ? (caregiver['address'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      final province = (address['province'] ?? caregiver['province'])
          ?.toString();
      final district = (address['district'] ?? caregiver['district'])
          ?.toString();
      // ระวังคีย์ subDistrict / subdistrict / subDistrictName ฯลฯ
      final subdistrict =
          (address['subdistrict'] ??
                  address['subDistrict'] ??
                  caregiver['subdistrict'] ??
                  caregiver['subDistrict'])
              ?.toString();

      // ดึง districtId/subdistrictId
      final districtId = (address['districtId'] ?? caregiver['districtId'])
          ?.toString()
          .trim();
      final subdistrictId =
          (address['subdistrictId'] ?? caregiver['subdistrictId'])
              ?.toString()
              .trim();

      // (C) name
      // รองรับ: caregiver['profile'] หรือ root
      final profile = (caregiver['profile'] is Map)
          ? (caregiver['profile'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      final firstName = (profile['firstName'] ?? caregiver['firstName'])
          ?.toString();
      final lastName = (profile['lastName'] ?? caregiver['lastName'])
          ?.toString();

      // ---------------------------
      // 2) เขียนตารางงานส่วนตัว caregiver/{uid}/schedule/{slotId}
      // ---------------------------
      final scheduleRef = FirebaseFirestore.instance
          .collection('caregiver')
          .doc(uid)
          .collection('schedule')
          .doc(slotId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(scheduleRef);

        final data = {
          'date': Timestamp.fromDate(serviceDateTime),
          'dateKey': dk,
          'time': _formatTime24(selectedTime),
          'timeKey': tk,
          'status': selectedStatus,
          'isAvailable': selectedStatus == 'ว่างงาน',
          'uid': uid,
          'slotId': slotId,

          // เพิ่ม id สำหรับ matching (เก็บใน schedule ด้วย)
          'districtId': districtId,
          'subdistrictId': subdistrictId,

          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (!snap.exists) {
          tx.set(scheduleRef, {
            ...data,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          tx.set(scheduleRef, data, SetOptions(merge: true));
        }
      });

      // ---------------------------
      // 3) เขียนตารางกลาง caregiver_slots/{uid}_{slotId}
      // ---------------------------
      final slotDocId = '${uid}_$slotId';
      await FirebaseFirestore.instance
          .collection('caregiver_slots')
          .doc(slotDocId)
          .set({
            'uid': uid,
            'slotId': slotId,

            // query/เรียง
            'date': Timestamp.fromDate(serviceDateTime),
            'dateKey': dk,
            'time': _formatTime24(selectedTime),
            'timeKey': tk,

            // สถานะ
            'status': selectedStatus,
            'isAvailable': selectedStatus == 'ว่างงาน',

            // matching fields
            'province': province,
            'district': district,
            'subdistrict': subdistrict,

            // เพิ่ม id สำหรับ matching
            'districtId': districtId,
            'subdistrictId': subdistrictId,

            'caregiverType': caregiverType,
            'firstName': firstName,
            'lastName': lastName,

            // metadata
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScheduleScreen()),
        (route) => false,
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกไม่สำเร็จ: ${e.message ?? e.code}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
