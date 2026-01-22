import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/screens/add_schedule_screen.dart';

class ScheduleHomeScreen extends StatefulWidget {
  const ScheduleHomeScreen({super.key});

  @override
  State<ScheduleHomeScreen> createState() => _ScheduleHomeScreentState();
}

class _ScheduleHomeScreentState extends State<ScheduleHomeScreen> {
  // ✅ Bottom nav index
  int _currentIndex = 0;

  // ✅ ข้อมูลตารางงานแบบ List ธรรมดา (ใส่ของจริงของคุณได้เลย)
  final List<Job> allJobs = [
    Job(
      start: DateTime(2026, 1, 23, 8, 0),
      end: DateTime(2026, 1, 23, 15, 0),
      receiver: "นลินภิชา วรรยกุล",
      pickup: "บ้าน ฟ้าภาพฤกษ์ 58 ... นนทบุรี 11000",
      dest: "โรงพยาบาลพระนั่งเกล้า นนทบุรี",
      note: "มีลิฟต์ และผู้ป่วยไม่สามารถเดินเองได้",
    ),
  ];

  DateTime selected = _dateOnly(DateTime.now());
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _setupMidnightTimer();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  // ✅ ให้วันที่เปลี่ยนเองตอนเที่ยงคืน (optional)
  void _setupMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final wait = nextMidnight.difference(now);

    _midnightTimer = Timer(wait, () {
      if (!mounted) return;
      setState(() {
        final prevToday = _dateOnly(now);
        final today = _dateOnly(DateTime.now());
        if (selected == prevToday) selected = today;
      });
      _setupMidnightTimer();
    });
  }

  // ---------- Date helpers ----------
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _weekStart(DateTime d) {
    final dd = _dateOnly(d);
    return dd.subtract(
      Duration(days: dd.weekday - DateTime.monday),
    ); // เริ่มวันจันทร์
  }

  List<DateTime> _weekDays(DateTime anchor) {
    final start = _weekStart(anchor);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  String _wd(DateTime d) {
    const m = {
      DateTime.monday: "จ",
      DateTime.tuesday: "อ",
      DateTime.wednesday: "พ",
      DateTime.thursday: "พฤ",
      DateTime.friday: "ศ",
      DateTime.saturday: "ส",
      DateTime.sunday: "อา",
    };
    return m[d.weekday]!;
  }

  // ---------- Filter jobs ----------
  // ✅ แสดงเฉพาะงานในสัปดาห์ที่เลือก
  List<Job> _jobsOfSelectedWeek() {
    final start = _weekStart(selected);
    final end = start.add(const Duration(days: 7));
    return allJobs
        .where(
          (j) =>
              j.start.isAfter(start.subtract(const Duration(seconds: 1))) &&
              j.start.isBefore(end),
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  // ✅ แสดงเฉพาะงานใน "วันที่เลือก" (แต่กรองจากงานในสัปดาห์ก่อน)
  List<Job> _jobsOfSelectedDay() {
    final weekJobs = _jobsOfSelectedWeek();
    return weekJobs.where((j) => _dateOnly(j.start) == selected).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);
    const bg = Color(0xFFFFF7EF);

    final days = _weekDays(selected);
    final headerDate = DateFormat("EEEE, d MMMM y", "th_TH").format(selected);
    final jobsToday = _jobsOfSelectedDay();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Header --------
              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFEAEAEA),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "สวัสดี!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "ชลธิชา รัตนกุล",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                height: 2,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Color(0xFFFF7A00),
              ),

              const SizedBox(height: 12),
              const Text(
                "ตารางงาน",
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w800
                ),
              ),
              Text(
                headerDate,
                style: const TextStyle(
                  fontSize: 14, 
                  color: Colors.grey
                ),
              ),

              const SizedBox(height: 12),

              // -------- Week selector --------
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final d = days[i];
                    final isSel = _dateOnly(d) == selected;

                    return InkWell(
                      onTap: () => setState(() => selected = _dateOnly(d)),
                      child: Container(
                        width: 52,
                        decoration: BoxDecoration(
                          color: isSel ? orange : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSel ? orange : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _wd(d),
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.grey,
                              ),
                            ),
                            Text(
                              "${d.day}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isSel ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // -------- Jobs list (ไม่ใช้ Stream) --------
              Expanded(
                child: jobsToday.isEmpty
                    ? const Center(child: Text("ไม่มีตารางงานวันนี้"))
                    : ListView.separated(
                        itemCount: jobsToday.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => JobCard(job: jobsToday[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- UI card (ง่ายๆ) ----------
class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);

    final dateText = DateFormat("d MMMM y", "th_TH").format(job.start);
    final timeText =
        "${DateFormat("HH:mm").format(job.start)} - ${DateFormat("HH:mm").format(job.end)}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "$dateText $timeText",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    "ยกเลิกนัดหมาย",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "ผู้รับบริการ: ${job.receiver}",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("ดูรายละเอียด"),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "📍 ${job.pickup}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "🏥 ${job.dest}",
                  style: const TextStyle(color: Colors.grey),
                ),
                if (job.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    "หมายเหตุ: ${job.note}",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Data model ----------
class Job {
  final DateTime start;
  final DateTime end;
  final String receiver;
  final String pickup;
  final String dest;
  final String note;

  const Job({
    required this.start,
    required this.end,
    required this.receiver,
    required this.pickup,
    required this.dest,
    required this.note,
  });
}
