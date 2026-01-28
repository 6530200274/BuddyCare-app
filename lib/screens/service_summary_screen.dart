import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/providers/questionnaire_provider.dart';
import 'package:my_app/screens/match_caretaker_screen.dart';
import 'package:my_app/screens/select_datetime_screen.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/meeting_point_provider.dart';
import '../providers/recipient_provider.dart';
import '../providers/selected_package_provider.dart';

class ServiceSummaryScreen extends StatelessWidget {
  const ServiceSummaryScreen({super.key});

  String _formatDateTh(DateTime? d) {
    if (d == null) return "-";
    return DateFormat("d MMMM yyyy", "th").format(d);
  }

  String _formatPrice(double? price) {
    if (price == null) return "-";
    // price
    return "${NumberFormat('#,##0.00').format(price)} บาท";
  }

  @override
  Widget build(BuildContext context) {
    final pkg = context.watch<SelectedPackageProvider>().selected;
    final recipient = context.watch<RecipientProvider>().profile;
    final meeting = context.watch<MeetingPointProvider>().data;
    final booking = context.watch<BookingProvider>().data;

    // จุดนัดพบ
    final pickupText = (meeting == null)
        ? "-"
        : "${meeting.address} "
              "${meeting.subdistrictName} ${meeting.districtName} "
              "${meeting.province} ${meeting.postcode}";

    // ปลายทาง (โรงพยาบาล)
    final destinationText = (meeting == null)
        ? "-"
        : "${meeting.hospitalName} จังหวัด${meeting.destProvince}";

    final recipientName = (recipient == null)
        ? "-"
        : "${recipient.firstName} ${recipient.lastName}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFFFA726),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectDateTimeScreen(),
                    ),
                  );
                },
                child: const Icon(
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
          'รายละเอียดผู้รับบริการ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(
              label: "บริการ:",
              value: pkg == null ? "-" : "${pkg.title}\n${pkg.description}",
            ),
            const SizedBox(height: 8),
            _row(label: "ค่าบริการ:", value: _formatPrice(pkg?.price)),
            _divider(),
            _row(label: "ผู้รับบริการ:", value: recipientName),
            _divider(),
            _row(label: "จุดนัดพบ:", value: pickupText),
            const SizedBox(height: 8),
            _row(label: "เดินทางไปยัง:", value: destinationText),
            _divider(),

            _row(
              label: "วันที่รับบริการ:",
              value: _formatDateTh(booking.serviceDate),
            ),

            _row(
              label: "เวลา:",
              value: (booking.serviceTime?.isNotEmpty ?? false)
                  ? "${booking.serviceTime!} น."
                  : "-",
            ),
            _divider(),

            const SizedBox(height: 10),
            const Text(
              "หมายเหตุ:",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              "1. ทุก Package ให้บริการสูงสุด 8 ชั่วโมง หากเกิน 8 ชั่วโมง \n มีค่าบริการล่วงเวลา 200 บาท/ชั่วโมง\n"
              "2. ค่าบริการนอกพื้นที่เพิ่ม 200 บาท\n"
              "3. ค่าใช้จ่ายทั้งหมดรวมภาษีมูลค่าเพิ่มเรียบร้อยแล้ว\n"
              "4. ผู้รับบริการต้องการจองหรือยกเลิกการจองคิวผู้ดูแลก่อนถึงวันนัดหมายภายใน 1 วัน\n",
              style: TextStyle(
                color: Color(0xFFFF6701),
                height: 1.35,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6701),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  final pkg = context.read<SelectedPackageProvider>().selected;
                  final recipient = context.read<RecipientProvider>().profile;
                  final meeting = context.read<MeetingPointProvider>().data;
                  final booking = context.read<BookingProvider>().data;
                  // ignore: unused_local_variable
                  final adl = context.read<ADLProvider>().result;

                  // เช็คข้อมูลจำเป็นก่อน
                  if (pkg == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("กรุณาเลือกแพ็กเกจก่อน")),
                    );
                    return;
                  }

                  if (recipient == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("กรุณากรอกข้อมูลผู้รับบริการก่อน"),
                      ),
                    );
                    return;
                  }

                  if (meeting == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("กรุณาเลือกจุดนัดพบก่อน")),
                    );
                    return;
                  }

                  if (booking.serviceDate == null ||
                      booking.serviceTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("กรุณาเลือกวันและเวลาให้ครบ"),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MatchCaregiverScreen(),
                    ),
                  );
                },
                child: const Text(
                  "ค้นหา",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1, thickness: 1, color: Color(0xFFFF6701)),
  );

  Widget _row({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}
