import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/screens/meeting_point_screen.dart';
import 'package:my_app/screens/service_summary_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/booking_provider.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({super.key});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  // final _firestoreService = BookingFirestoreService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;

  final List<String> _timeOptions = const [
    "05:00",
    "06:00",
    "07:00",
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
  ];

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _onlyDate(now);
    final minBookDate = today.add(
      const Duration(days: 2),
    ); // ต้องล่วงหน้า 2 วัน

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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MeetingPointScreen()),
                );
              },
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
          "เลือกวันเวลาที่รับบริการ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 1.2),
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    locale: 'th_TH',
                    firstDay: today.subtract(const Duration(days: 365)),
                    lastDay: today.add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        _selectedDay != null && isSameDay(_selectedDay, day),
                    enabledDayPredicate: (day) {
                      // เลือกได้เฉพาะตั้งแต่ minBookDate เป็นต้นไป
                      return !day.isBefore(minBookDate);
                    },
                    onDaySelected: (selectedDay, focusedDay) async {
                      final s = _onlyDate(selectedDay);

                      // ถ้ากด "วันนี้" ให้เด้งเตือน
                      if (s.isAtSameMomentAs(today)) {
                        await _showMustBookOneDayAheadDialog(context);
                        return;
                      }

                      // ถ้าเป็นวันก่อนพรุ่งนี้ 
                      if (s.isBefore(minBookDate)) {
                        await _showMustBookOneDayAheadDialog(context);
                        return;
                      }

                      setState(() {
                        _selectedDay = s;
                        _focusedDay = focusedDay;
                      });

                      // เก็บไว้ใน Provider เพื่อไปหน้าถัดไป
                      context.read<BookingProvider>().setServiceDate(s);
                    },
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(Icons.chevron_left),
                      rightChevronIcon: Icon(Icons.chevron_right),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFFF6701), width: 1.5),
                        color: Colors.transparent,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFFFF6701),
                        shape: BoxShape.circle,
                      ),
                      disabledTextStyle: const TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, size: 16, color: Color(0xFFFF6701)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "กรุณาจองล่วงหน้าก่อน 2 วันก่อนวันนัดหมาย",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("วันที่รับบริการ"),
                      const SizedBox(height: 8),
                      _readonlyBox(
                        text: _selectedDay == null
                            ? ""
                            : DateFormat(
                                'd MMMM yyyy',
                                'th_TH',
                              ).format(_selectedDay!),
                      ),
                      const SizedBox(height: 12),
                      const Text("เวลาที่รับบริการ"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTime,
                        decoration: InputDecoration(
                          hintText: "กรุณาเลือกเวลา",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: _timeOptions
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedTime = v);
                          if (v != null) {
                            context.read<BookingProvider>().setServiceTime(v);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6701),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    onPressed: () {
                      if (_selectedDay == null || _selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("กรุณาเลือกวันและเวลาให้ครบ"),
                          ),
                        );
                        return;
                      }

                      //เก็บลง Provider
                      final bookingProvider = context.read<BookingProvider>();
                      bookingProvider.setServiceDate(_selectedDay!);
                      bookingProvider.setServiceTime(_selectedTime!);

                      //ไปหน้า ServiceSummaryScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServiceSummaryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "บันทึก",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _readonlyBox({required String text}) {
    return Container(
      height: 46,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }

  Future<void> _showMustBookOneDayAheadDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ไม่สามารถจองวันนี้ได้"),
        content: const Text("ไม่สามารถทำการจองได้\nต้องทำการจองล่วงหน้า 1 วัน"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }
}
