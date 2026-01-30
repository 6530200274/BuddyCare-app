import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/caregiver_login_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  static const Color kOrange = Color(0xFFFF7A00);
  static const Color kBg = Colors.white;
  static const Color kHint = Color(0xFFBDBDBD);
  static const Color kBorder = Color(0xFFE5E5E5);
  static const Color kText = Color(0xFF222222);

  final _formKey = GlobalKey<FormState>();

  String? _year;
  String? _level;

  final _schoolCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();

  String? _uploadedFileName;

  final _years = const ['2566', '2565', '2564', '2563', '2562'];
  final _levels = const [
    'มัธยมศึกษา',
    'ปวช.',
    'ปวส.',
    'ปริญญาตรี',
    'ปริญญาโท',
    'ปริญญาเอก',
  ];

  @override
  void dispose() {
    _schoolCtrl.dispose();
    _majorCtrl.dispose();
    super.dispose();
  }

  String? _requiredText(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกข้อมูล';
    return null;
  }

  String? _requiredDropdown(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณาเลือก';
    return null;
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kHint, fontSize: 13),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kOrange, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: kOrange, fontWeight: FontWeight.w800),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFileMock() async {
    // เปลี่ยนเป็น file_picker ได้ภายหลัง
    setState(() => _uploadedFileName = 'transcript.pdf');
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_uploadedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาอัพโหลดใบรับรองการศึกษา')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเข้าสู่ระบบใหม่')));
      return;
    }

    try {
      final caregiverRef = FirebaseFirestore.instance
          .collection('caregiver')
          .doc(uid);

      final now = Timestamp.now();

      final edu = {
        'year': _year,
        'school': _schoolCtrl.text.trim(),
        'major': _majorCtrl.text.trim(),
        'level': _level,
        'transcriptFileName': _uploadedFileName,
        'createdAt': now,
        'updatedAt': now,
      };

      await caregiverRef.set({
        'updatedAt': FieldValue.serverTimestamp(),
        'education': edu, // ✅ เป็น Map ไม่ใช่ Array
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลการศึกษาเรียบร้อย')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CaregiverLoginScreen()),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kOrange,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'เพิ่มการศึกษา',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36), // balance
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== Card Form =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ปีการศึกษา*
                        _label('ปีที่จบการศึกษา', required: true),
                        DropdownButtonFormField<String>(
                          value: _year,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF9E9E9E),
                          ),
                          decoration: _inputDecoration(hint: 'กรุณาเลือก'),
                          items: _years
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _year = v),
                          validator: _requiredDropdown,
                        ),
                        const SizedBox(height: 12),

                        // สถาบัน*
                        _label('สถาบัน', required: true),
                        TextFormField(
                          controller: _schoolCtrl,
                          decoration: _inputDecoration(hint: 'กรอกสถาบัน'),
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 12),

                        // คณะ/สาขา/หลักสูตร*
                        _label('คณะ/สาขา/หลักสูตร', required: true),
                        TextFormField(
                          controller: _majorCtrl,
                          decoration: _inputDecoration(
                            hint: 'กรอกคณะ/สาขา/หลักสูตร',
                          ),
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 12),

                        // ระดับการศึกษา*
                        _label('ระดับการศึกษา', required: true),
                        DropdownButtonFormField<String>(
                          value: _level,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF9E9E9E),
                          ),
                          decoration: _inputDecoration(hint: 'กรุณาเลือก'),
                          items: _levels
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _level = v),
                          validator: _requiredDropdown,
                        ),
                        const SizedBox(height: 12),

                        // ใบรับรองการศึกษา* + upload box
                        _label('ใบรับรองการศึกษา', required: true),
                        Container(
                          height: 64,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                            child: SizedBox(
                              height: 34,
                              child: ElevatedButton(
                                onPressed: _pickFileMock,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                                child: Text(
                                  _uploadedFileName == null
                                      ? 'อัพโหลด'
                                      : 'อัพโหลดแล้ว',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (_uploadedFileName != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'ไฟล์: $_uploadedFileName',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== Bottom Save Button =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: 150,
                height: 44,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
