import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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

  String _formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);
    const bg = Color(0xFFFFF7EF);
    const yellow = Color(0xFFFEA82F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,

        // ปุ่มกลับ
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: yellow,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
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
            SizedBox(height: 10),
            // -------- ปฏิทิน --------
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: (newDate) {
                setState(() {
                  selectedDate = newDate;
                });
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

            SizedBox(height: 8),

            GestureDetector(
              onTap: () => _openDatePicker(context),
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

            // -------- ฟอร์มเลือกเวลาที่รับบริการ --------
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
              onTap: () => _openTimePicker(context),
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

            // -------- ฟอร์มเลือกสถานะตารางงาน --------
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
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
              ),
            ),

            // -------- ปุ่มบันทึก --------
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
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

  _openDatePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
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
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _onSave() {
    // รวมวันที่ + เวลา เป็น DateTime เดียว
    final DateTime serviceDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    debugPrint('วันที่เวลา: $serviceDateTime');
    debugPrint('สถานะ: $selectedStatus');

    // TODO:
    // - บันทึกลง Firebase
    // - ส่งค่ากลับหน้าก่อนหน้า
    // - แสดง Snackbar แจ้งสำเร็จ

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')));

    Navigator.pop(context);
  }
}
