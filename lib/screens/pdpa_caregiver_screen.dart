import 'package:flutter/material.dart';

class PdpaCaregiverScreen extends StatefulWidget {
  const PdpaCaregiverScreen({super.key});

  @override
  State<PdpaCaregiverScreen> createState() => _PdpaCaregiverScreenState();
}

class _PdpaCaregiverScreenState extends State<PdpaCaregiverScreen> {
  static const Color kOrange = Color(0xFFFF7A00);
  static const Color kTextDark = Color(0xFF111111);
  static const Color kTextGrey = Color(0xFF777777);
  static const Color kBorder = Color(0xFFE9E9E9);
  static const Color kYellow = Color(0xFFFEA82F);

  bool _agree1 = false;
  bool _agree2 = false;

  bool get _canNext => _agree1 && _agree2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: kYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "การยินยอมให้ใช้ข้อมูล",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 54),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "การให้ความยินยอมในการใช้และเปิดเผยข้อมูลส่วนบุคคล (PDPA)\n"
                      "เพื่อให้การให้บริการรับ-ส่งผู้ป่วยไปยังสถานพยาบาลเป็นไป\n"
                      "อย่างปลอดภัย เหมาะสม และทันสถานการณ์",
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: kTextGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: kTextGrey,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text:
                                "ผู้ใช้บริการจำเป็นต้องได้รับการยินยอมให้ใช้ข้อมูลของผู้ป่วยทาง",
                          ),
                          TextSpan(text: "ประวัติการรักษา"),
                          TextSpan(text: "รวมถึงข้อมูลส่วนบุคคลทั่วไป และ "),
                          TextSpan(
                            text: "ข้อมูลสุขภาพ (ข้อมูลอ่อนไหว)",
                            style: TextStyle(color: kOrange),
                          ),
                          TextSpan(text: " ดังต่อไปนี้"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "1. ประเภทข้อมูลที่อาจมีการเปิดเผย",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: kTextGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    _subDot(
                      "ข้อมูลส่วนบุคคล เช่น ชื่อ-นามสกุล อายุ เพศ ข้อมูลการติดต่อ",
                    ),
                    _subDot("ข้อมูลส่วนสุขภาพ เช่น"),
                    _subDot("อาการเจ็บป่วยหรือโรคประจำตัว"),
                    _subDot("ข้อมูลการป่วยในปัจจุบัน"),
                    _subDot(
                      "ข้อมูลระวังพิเศษระหว่างการเดินทาง (เช่น ต้องใช้รถเข็น ออกซิเจน หรือช่วยพยุง)",
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "2. วัตถุประสงค์ในการใช้ข้อมูล",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: kTextGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _subDot(
                      "เพื่อให้ผู้ใช้บริการช่วยเรียกรถมาพร้อมและให้ความช่วยเหลือผู้ป่วยได้อย่างเหมาะสม",
                    ),
                    _subDot("เพื่อความปลอดภัยของผู้ป่วยตลอดการเดินทาง"),
                    _subDot(
                      "เพื่ออำนวยความสะดวกในการให้บริการรับ-ส่งผู้ป่วยไปยังสถานพยาบาลที่กำหนด",
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "3. การคุ้มครองข้อมูล",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: kTextGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _subDot("ผู้รับรถตกลงว่าจะ:"),
                    _subDotRich(
                      leading: "ใช้ข้อมูลดังกล่าว ",
                      highlight: "เฉพาะเท่าที่จำเป็น",
                      trailing: " สำหรับการให้บริการ",
                    ),
                    _subDot(
                      "ไม่บันทึก เผยแพร่ ส่งต่อ หรือใช้ข้อมูลผู้ป่วยกับวัตถุประสงค์อื่น",
                    ),
                    _subDot(
                      "รักษาความลับของข้อมูลตามกฎหมายคุ้มครองข้อมูลส่วนบุคคล (PDPA)",
                    ),

                    const SizedBox(height: 18),
                    Container(height: 1, color: kBorder),
                    const SizedBox(height: 10),

                    _agreeTile(
                      value: _agree1,
                      onChanged: (v) => setState(() => _agree1 = v ?? false),
                      text:
                          "ข้าพเจ้าได้อ่านและเข้าใจรายละเอียดข้างต้น และยินยอมให้ใช้และเปิดเผยข้อมูลส่วนบุคคลและข้อมูลสุขภาพของผู้ป่วย ตามวัตถุประสงค์ที่ระบุไว้",
                    ),
                    const SizedBox(height: 6),
                    _agreeTile(
                      value: _agree2,
                      onChanged: (v) => setState(() => _agree2 = v ?? false),
                      text:
                          "ข้าพเจ้าได้อ่านและเข้าใจรายละเอียดข้างต้น และยินยอมให้ใช้และเปิดเผยข้อมูลส่วนบุคคลและข้อมูลสุขภาพของผู้ป่วย ตามวัตถุประสงค์ที่ระบุไว้",
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canNext
                      ? () {
                          // TODO: ไปหน้าถัดไป
                          // Navigator.push(...);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    disabledBackgroundColor: kOrange.withOpacity(0.35),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    "ต่อไป",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subDot(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 14, height: 1.3, color: kTextGrey),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: kTextGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subDotRich({
    required String leading,
    required String highlight,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 14, height: 1.3, color: kTextGrey),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: kTextGrey,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(text: leading),
                  TextSpan(
                    text: highlight,
                    style: const TextStyle(color: kOrange),
                  ),
                  TextSpan(text: trailing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _agreeTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.05,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: kOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: kTextDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
