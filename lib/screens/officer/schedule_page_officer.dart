import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleHomeScreen extends StatefulWidget {
  const ScheduleHomeScreen({super.key});

  @override
  State<ScheduleHomeScreen> createState() => _ScheduleHomeScreenState();
}

class _ScheduleHomeScreenState extends State<ScheduleHomeScreen> {
  DateTime _today =
      DateTime.now(); //เก็บวันที่ปัจจุบัน เวลาเปลี่ยน->เปลี่ยนค่าตัวนี้-> UI เปลี่ยน
  Timer? _midnightTimer; //ตัวจับเวลา ใช้รอจนถึงเที่ยงคืน

  @override
  void initState() {
    //initState() ถูกเรียกครั้งเดียว
    super.initState();
    _scheduleMidnightUpdate();
  }

  void _scheduleMidnightUpdate() {
    final now = DateTime.now(); //เวลาปัจจุบันจริง
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ); //สร้างเวลา เที่ยงคืนของวันถัดไป
    final duration = nextMidnight.difference(
      now,
    ); //คำนวณว่าจากตอนนี้ → เที่ยงคืน เหลือกี่ชั่วโมง/นาที

    _midnightTimer = Timer(duration, () {
      //ตั้งTimer เมื่อเวลาครบ duration → โค้ดข้างในจะถูกรันทันที
      setState(() {
        _today = DateTime.now(); //ข้อมูลเปลี่ยนแล้ว วาดหน้าจอใหม่ด้วย
      });
      _scheduleMidnightUpdate(); //ตั้งรอบถัดไป
    });
  }

  @override
  void dispose() {
    //เมื่อออกจากหน้านี้ ยกเลิก Timer ทิ้ง
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);
    const bg = Color(0xFFFFF7EF);

    final dateText = DateFormat(
      'EEEE, d MMMM yyyy',
      'th',
    ).format(_today); //แปลง _today เป็นข้อความ

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- เส้นแบ่ง --------
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      dateText,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
