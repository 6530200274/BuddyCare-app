import 'dart:async';
import 'package:flutter/material.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  // สีธีมใกล้เคียงภาพ
  static const Color kOrange = Color(0xFFFF6A00);
  static const Color kTextDark = Color(0xFF222222);
  static const Color kTextGrey = Color(0xFF8C8C8C);
  static const Color kBg = Color(0xFFF7F7F7);

  int _bottomIndex = 0;

  // ====== REALTIME DATE ======
  late DateTime _today; // ใช้เป็นฐาน (อัปเดตเมื่อข้ามวัน)
  late List<_DayChip> _days;
  int _selectedDayIndex = 0;

  Timer? _midnightTimer;

  // shifts (ตัวอย่าง) -> แนะนำเก็บเป็น DateTime เพื่อเรียลไทม์ได้ง่าย
  final List<_ShiftItem> _shifts = [
    _ShiftItem(date: DateTime(2026, 1, 23), time: "08:00 - 15:00"),
    _ShiftItem(date: DateTime(2026, 1, 24), time: "08:00 - 15:00"),
  ];

  @override
  void initState() {
    super.initState();
    _refreshTodayAndDays();      // ตั้งค่า “วันนี้” + สร้างแถบวัน
    _scheduleMidnightRefresh();  // ตั้ง timer อัปเดตตอนเที่ยงคืน
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  void _refreshTodayAndDays() {
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);

    _days = _buildWeekChips(_today); // สร้าง จ-อา ของสัปดาห์นี้
    _selectedDayIndex = _indexOfDateInDays(_today); // default เลือก “วันนี้”
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final duration = nextMidnight.difference(now);

    _midnightTimer = Timer(duration, () {
      if (!mounted) return;
      setState(() {
        _refreshTodayAndDays();
      });
      _scheduleMidnightRefresh(); // ตั้งใหม่สำหรับวันถัดไป
    });
  }

  List<_DayChip> _buildWeekChips(DateTime anchorDay) {
    // ทำให้สัปดาห์เริ่มวันจันทร์
    final monday = anchorDay.subtract(Duration(days: anchorDay.weekday - DateTime.monday));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return _DayChip(date: d);
    });
  }

  int _indexOfDateInDays(DateTime d) {
    for (int i = 0; i < _days.length; i++) {
      if (_isSameDate(_days[i].date, d)) return i;
    }
    return 0;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime get _selectedDate => _days[_selectedDayIndex].date;

  // ====== THAI FORMATTERS (พ.ศ.) ======
  static const List<String> _thaiWeekdaysFull = [
    "จันทร์",
    "อังคาร",
    "พุธ",
    "พฤหัสบดี",
    "ศุกร์",
    "เสาร์",
    "อาทิตย์",
  ];

  static const List<String> _thaiWeekdaysShort = ["จ", "อ", "พ", "พฤ", "ศ", "ส", "อา"];

  static const List<String> _thaiMonths = [
    "มกราคม",
    "กุมภาพันธ์",
    "มีนาคม",
    "เมษายน",
    "พฤษภาคม",
    "มิถุนายน",
    "กรกฎาคม",
    "สิงหาคม",
    "กันยายน",
    "ตุลาคม",
    "พฤศจิกายน",
    "ธันวาคม",
  ];

  String _formatHeaderLine(DateTime d) {
    final weekday = _thaiWeekdaysFull[d.weekday - 1];
    final day = d.day;
    final month = _thaiMonths[d.month - 1];
    final yearBE = d.year + 543;
    return "$weekday, $day $month $yearBE";
  }

  String _formatDateTh(DateTime d) {
    final day = d.day;
    final month = _thaiMonths[d.month - 1];
    final yearBE = d.year + 543;
    return "$day $month $yearBE";
  }

  String _weekdayShortTh(DateTime d) => _thaiWeekdaysShort[d.weekday - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(), // ✅ ใช้วันที่เรียลไทม์แล้ว
                    const SizedBox(height: 10),
                    _buildDaySelector(), // ✅ สร้างจากสัปดาห์ปัจจุบัน
                    const SizedBox(height: 14),
                    ..._buildShiftsForSelectedDay(),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kOrange,
        onPressed: () {
          // TODO: ไปหน้าเพิ่มตารางงาน
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9E9E9),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "สวัสดี!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "ชลธิชา รัตนกุล",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ตารางงาน",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatHeaderLine(_selectedDate), // ✅ เรียลไทม์ + ตามวันที่ที่เลือก
              style: const TextStyle(
                fontSize: 12,
                color: kTextGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // TODO: เปิดปฏิทิน
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_month, color: kOrange, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 66,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = _days[i];
          final selected = i == _selectedDayIndex;

          return InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => setState(() => _selectedDayIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? kOrange : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: selected ? kOrange : const Color(0xFFE5E5E5),
                  width: 1,
                ),
                boxShadow: [
                  if (selected)
                    BoxShadow(
                      color: kOrange.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayShortTh(d.date), // ✅ ดึงจาก DateTime
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : kTextGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${d.date.day}", // ✅ ดึงจาก DateTime
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : kTextDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildShiftsForSelectedDay() {
    // ตัวอย่าง: filter เฉพาะ shift ของวันที่เลือก
    final list = _shifts.where((s) => _isSameDate(s.date, _selectedDate)).toList();

    if (list.isEmpty) {
      return [
        _buildEmptyCard(),
      ];
    }

    return list.map(_buildShiftCard).toList();
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.circle, size: 10, color: Color(0xFFBDBDBD)),
          SizedBox(width: 10),
          Text(
            "ไม่มีตารางงานในวันนี้",
            style: TextStyle(
              color: kTextGrey,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(_ShiftItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${_formatDateTh(item.date)} ${item.time}", // ✅ เรียลไทม์จาก DateTime
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _iconButton(
                    icon: Icons.edit,
                    onTap: () {
                      // TODO: แก้ไขรายการ
                    },
                  ),
                  const SizedBox(width: 8),
                  _iconButton(
                    icon: Icons.delete_outline,
                    onTap: () {
                      // TODO: ลบรายการ
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 10, color: Color(0xFFBDBDBD)),
                  SizedBox(width: 10),
                  Text(
                    "ว่างงาน",
                    style: TextStyle(
                      color: kTextGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _bottomIndex,
      onTap: (i) => setState(() => _bottomIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kOrange,
      unselectedItemColor: const Color(0xFF9E9E9E),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "หน้าแรก"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "ข้อความ"),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "เพิ่มตารางงาน"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "แจ้งเตือน"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "โปรไฟล์"),
      ],
    );
  }
}

class _DayChip {
  final DateTime date;
  const _DayChip({required this.date});
}

class _ShiftItem {
  final DateTime date;
  final String time;
  const _ShiftItem({required this.date, required this.time});
}
