import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleHomeScreen extends StatefulWidget {
  const ScheduleHomeScreen({super.key});

  @override
  State<ScheduleHomeScreen> createState() => _ScheduleHomeScreenState();
}

class _ScheduleHomeScreenState extends State<ScheduleHomeScreen> {
  DateTime _today = DateTime.now();
  Timer? _midnightTimer;

  // ===== Weekly =====
  late List<DateTime> _weekDays; // 7 วัน (จ-อา)
  int _selectedIndex = 0;

  static const orange = Color(0xFFFF7A00);
  static const bg = Color(0xFFFFF7EF);

  @override
  void initState() {
    super.initState();
    _rebuildWeek(); // สร้างสัปดาห์ครั้งแรก
    _scheduleMidnightUpdate();
  }

  void _scheduleMidnightUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    _midnightTimer = Timer(duration, () {
      setState(() {
        _today = DateTime.now();
        _rebuildWeek(); // ข้ามวันแล้วสัปดาห์อาจเปลี่ยน ต้อง rebuild
        _selectedIndex = _indexOfDateInWeek(_today) ?? 0;
      });
      _scheduleMidnightUpdate();
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  // ===== Helpers =====
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int? _indexOfDateInWeek(DateTime d) {
    final target = _dateOnly(d);
    for (int i = 0; i < _weekDays.length; i++) {
      if (_dateOnly(_weekDays[i]) == target) return i;
    }
    return null;
  }

  DateTime _startOfWeekMonday(DateTime d) {
    // weekday: Mon=1 ... Sun=7
    final date = _dateOnly(d);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  void _rebuildWeek() {
    final start = _startOfWeekMonday(_today);
    _weekDays = List.generate(7, (i) => start.add(Duration(days: i)));

    // ให้ default เลือก "วันนี้" ถ้ามีในสัปดาห์นี้
    _selectedIndex = _indexOfDateInWeek(_today) ?? 0;
  }

  String _thaiDayShort(DateTime d) {
    // จ อ พ พฤ ศ ส อา (ตามที่เห็นในรูป)
    switch (d.weekday) {
      case DateTime.monday:
        return 'จ';
      case DateTime.tuesday:
        return 'อ';
      case DateTime.wednesday:
        return 'พ';
      case DateTime.thursday:
        return 'พฤ';
      case DateTime.friday:
        return 'ศ';
      case DateTime.saturday:
        return 'ส';
      case DateTime.sunday:
        return 'อา';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _weekDays[_selectedIndex];

    final dateText = DateFormat('EEEE, d MMMM yyyy', 'th').format(selectedDate);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- เส้นแบ่ง --------
              Container(
                height: 2,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: orange,
              ),
              const SizedBox(height: 12),

              // -------- ตารางงานและวันที่ --------
              const Text(
                "ตารางงาน",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(
                dateText,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // ===== แถบรายสัปดาห์ (7 วัน) =====
              _WeeklyRow(
                days: _weekDays,
                selectedIndex: _selectedIndex,
                dayShort: _thaiDayShort,
                isToday: (d) => _dateOnly(d) == _dateOnly(_today),
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),

              // ส่วนอื่น ๆ ของหน้าคุณใส่ต่อได้เลย
              const SizedBox(height: 16),
              // Expanded(child: ...),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyRow extends StatelessWidget {
  const _WeeklyRow({
    required this.days,
    required this.selectedIndex,
    required this.dayShort,
    required this.isToday,
    required this.onTap,
  });

  final List<DateTime> days;
  final int selectedIndex;
  final String Function(DateTime) dayShort;
  final bool Function(DateTime) isToday;
  final void Function(int index) onTap;

  static const orange = Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(days.length, (i) {
        final d = days[i];
        final selected = i == selectedIndex;
        final today = isToday(d);

        // สไตล์ใกล้รูป: วงกลม + ตัวอักษรบน + เลขล่าง
        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ตัวอักษรวัน (จ/อ/พ...)
                Text(
                  dayShort(d),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? orange : const Color(0xFF3A3A3A),
                  ),
                ),
                const SizedBox(height: 8),

                // วงกลมเลขวันที่
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? orange : Colors.white,
                    border: Border.all(
                      color: selected
                          ? orange
                          : (today ? orange : const Color(0xFFE3E3E3)),
                      width: today && !selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : const Color(0xFF222222),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
