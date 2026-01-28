// member_register_form_caregiver_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import 'package:my_app/widgets/app_text_field.dart';
import 'package:my_app/widgets/primary_button.dart';
import 'package:my_app/theme/app_colors.dart';

class MemberRegisterFormCaregiverScreen extends StatefulWidget {
  const MemberRegisterFormCaregiverScreen({super.key});

  @override
  State<MemberRegisterFormCaregiverScreen> createState() =>
      _MemberRegisterFormCaregiverScreenState();
}

class _MemberRegisterFormCaregiverScreenState
    extends State<MemberRegisterFormCaregiverScreen> {
  final _formKey = GlobalKey<FormState>();

  // -------ข้อมูลทั่วไป-------
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _idCard = TextEditingController();
  final _dobText = TextEditingController();
  DateTime? _dob;

  String? _nationality;
  String? _religion;
  String? _gender;

  // -------ที่อยู่-------
  final _addrNo = TextEditingController();
  final _addrMoo = TextEditingController();
  final _addrVillage = TextEditingController();
  final _addrSoi = TextEditingController();
  final _addrBuilding = TextEditingController();
  final _addrRoom = TextEditingController();
  final _addrFloor = TextEditingController();
  final _addrRoad = TextEditingController();
  final _addrPostcode = TextEditingController();

  String? _province;
  String? _district;
  String? _subDistrict;

  // -------ข้อมูลอาชีพ-------
  String? _caregiverType;
  final _licenseNo = TextEditingController();
  String? _uploadedFileName;

  bool _loading = false;

  // ======= dropdown options =======
  final _nationalities = const [
    'ไทย',
    'จีน',
    'เกาหลี',
    'ญี่ปุ่น',
    'อังกฤษ',
    'อเมริกัน',
    'อื่นๆ',
  ];
  final _religions = const [
    'พุทธ',
    'คริสต์',
    'อิสลาม',
    'ฮินดู',
    'ไม่นับถือศาสนาใดๆ',
    'อื่นๆ',
  ];
  final _genders = const ['ชาย', 'หญิง', 'ไม่ระบุ'];
  final _caregiverTypes = const [
    'พยาบาลวิชาชีพ (RN)',
    'ผู้ช่วยพยาบาล (PN)',
    'ผู้ดูแล (NA/Caregiver)',
  ];

  // ======= address data from JSON (แทน const เดิมทั้งหมด) =======
  bool _addrReady = false;
  String? _addrLoadError;

  List<String> _provinces = [];
  final Map<String, List<String>> _districtsByProvince = {};
  final Map<String, List<String>> _subDistrictsByDistrict = {};
  final Map<String, String> _districtIdToName = {};

  @override
  void initState() {
    super.initState();
    _loadAddressJson();
  }

  Future<void> _loadAddressJson() async {
    try {
      // ✅ ใช้ไฟล์เดียวกับ MeetingPointScreen (ตอนนี้มีแค่กรุงเทพ)
      final str =
          await rootBundle.loadString('assets/bkk_master_district_subdistrict.json');
      final json = jsonDecode(str) as Map<String, dynamic>;

      final meta = (json['meta'] as Map<String, dynamic>);
      final provinceName = (meta['province_th'] as String).trim();

      final districts = (json['districts'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => DistrictMini(
                id: (e['id'] as String).trim(),
                nameTh: (e['name_th'] as String).trim(),
              ))
          .toList();

      final subdistricts = (json['subdistricts'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => SubdistrictMini(
                districtId: (e['district_id'] as String).trim(),
                nameTh: (e['name_th'] as String).trim(),
              ))
          .toList();

      // id -> ชื่อเขต
      _districtIdToName
        ..clear()
        ..addEntries(districts.map((d) => MapEntry(d.id, d.nameTh)));

      // จังหวัด -> รายชื่อเขต
      final districtNames = districts.map((d) => d.nameTh).toList();

      // เขต -> รายชื่อแขวง (อิง district_id)
      final Map<String, List<String>> subByDistrict = {};
      for (final s in subdistricts) {
        final districtName = _districtIdToName[s.districtId];
        if (districtName == null) continue;
        subByDistrict.putIfAbsent(districtName, () => []);
        subByDistrict[districtName]!.add(s.nameTh);
      }

      if (!mounted) return;
      setState(() {
        _provinces = [provinceName]; // ตอนนี้มีไฟล์เดียว => 1 จังหวัด
        _districtsByProvince
          ..clear()
          ..[provinceName] = districtNames;

        _subDistrictsByDistrict
          ..clear()
          ..addAll(subByDistrict);

        // default
        _province ??= provinceName;

        _addrReady = true;
        _addrLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _addrReady = false;
        _addrLoadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _idCard.dispose();
    _dobText.dispose();
    _addrNo.dispose();
    _addrMoo.dispose();
    _addrVillage.dispose();
    _addrSoi.dispose();
    _addrBuilding.dispose();
    _addrRoom.dispose();
    _addrFloor.dispose();
    _addrRoad.dispose();
    _addrPostcode.dispose();
    _licenseNo.dispose();
    super.dispose();
  }

  // ======= validators =======
  String? _requiredText(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกข้อมูล';
    return null;
  }

  String? _requiredDropdown(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณาเลือกข้อมูล';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 10) {
      return 'รูปแบบเบอร์โทรไม่ถูกต้อง';
    }
    return null;
  }

  String? _idCardValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกหมายเลขบัตรประชาชน';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 13) return 'เลขบัตรประชาชนต้องมี 13 หลัก';
    return null;
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 30, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'เลือกวันเกิด',
      cancelText: 'ยกเลิก',
      confirmText: 'ตกลง',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _dob = picked;
      _dobText.text = DateFormat('dd/MM/yyyy').format(picked);
    });
  }

  Future<void> _pickFile() async {
    setState(() {
      _uploadedFileName = 'ไฟล์ถูกเลือกแล้ว.pdf';
    });
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_uploadedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาอัพโหลดใบรับรอง')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hint),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Widget _profileHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE0E0E0),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'เพิ่มรูปโปรไฟล์',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // === address lists (หลังโหลด JSON) ===
    final districts = _province == null
        ? <String>[]
        : (_districtsByProvince[_province] ?? <String>[]);

    final subDistricts = _district == null
        ? <String>[]
        : (_subDistrictsByDistrict[_district] ?? <String>[]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFFFA726),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'ข้อมูลสมัครสมาชิก',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: Colors.white,
      body: !_addrReady
          ? Center(
              child: _addrLoadError == null
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 36),
                          const SizedBox(height: 10),
                          const Text(
                            'โหลดข้อมูลจังหวัด/เขตไม่สำเร็จ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _addrLoadError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadAddressJson,
                            child: const Text('ลองใหม่'),
                          ),
                        ],
                      ),
                    ),
            )
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _profileHeader(),

                    // -------ข้อมูลทั่วไป-------
                    _CardSection(
                      title: 'ข้อมูลทั่วไป',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'ชื่อ',
                            requiredMark: true,
                            hintText: 'กรอกชื่อ',
                            controller: _firstName,
                            validator: _requiredText,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'นามสกุล',
                            requiredMark: true,
                            hintText: 'กรอกนามสกุล',
                            controller: _lastName,
                            validator: _requiredText,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'เบอร์โทรศัพท์',
                            requiredMark: true,
                            hintText: 'กรอกเบอร์โทรศัพท์',
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            validator: _phoneValidator,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'หมายเลขบัตรประชาชน',
                            requiredMark: true,
                            hintText: 'กรอกหมายเลขบัตรประชาชน',
                            controller: _idCard,
                            keyboardType: TextInputType.number,
                            validator: _idCardValidator,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Label('สัญชาติ', required: true),
                                    DropdownButtonFormField<String>(
                                      value: _nationality,
                                      isExpanded: true,
                                      items: _nationalities
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _nationality = v),
                                      decoration:
                                          _dropdownDecoration('กรุณาเลือก'),
                                      validator: _requiredDropdown,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Label('ศาสนา', required: true),
                                    DropdownButtonFormField<String>(
                                      value: _religion,
                                      isExpanded: true,
                                      items: _religions
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _religion = v),
                                      decoration:
                                          _dropdownDecoration('กรุณาเลือก'),
                                      validator: _requiredDropdown,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'วันเดือนปีเกิด',
                                  requiredMark: true,
                                  hintText: 'ว/ด/ป',
                                  controller: _dobText,
                                  readOnly: true,
                                  onTap: _pickDob,
                                  validator: (_) =>
                                      _dob == null ? 'กรุณาเลือกวันเกิด' : null,
                                  suffixIcon: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Label('เพศ', required: true),
                                    DropdownButtonFormField<String>(
                                      value: _gender,
                                      isExpanded: true,
                                      items: _genders
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _gender = v),
                                      decoration:
                                          _dropdownDecoration('กรุณาเลือก'),
                                      validator: _requiredDropdown,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // -------ที่อยู่-------
                    _CardSection(
                      title: 'ที่อยู่ที่สามารถติดต่อได้ / ข้อมูลที่อยู่ปัจจุบัน',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'เลขที่',
                                  requiredMark: true,
                                  hintText: 'เลขที่',
                                  controller: _addrNo,
                                  validator: _requiredText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'หมู่ที่',
                                  hintText: 'หมู่ที่',
                                  controller: _addrMoo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'หมู่บ้าน',
                                  hintText: 'หมู่บ้าน',
                                  controller: _addrVillage,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'ตรอก/ซอย',
                                  hintText: 'ตรอก/ซอย',
                                  controller: _addrSoi,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'อาคาร',
                                  hintText: 'อาคาร',
                                  controller: _addrBuilding,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'ห้องเลขที่',
                                  hintText: 'ห้องเลขที่',
                                  controller: _addrRoom,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'ชั้น',
                                  hintText: 'ชั้น',
                                  controller: _addrFloor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'ถนน',
                                  hintText: 'ถนน',
                                  controller: _addrRoad,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // จังหวัด
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('จังหวัด', required: true),
                              DropdownButtonFormField<String>(
                                value: _province,
                                isExpanded: true,
                                items: _provinces
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _province = v;
                                    _district = null;
                                    _subDistrict = null;
                                  });
                                },
                                decoration: _dropdownDecoration('กรุณาเลือก'),
                                validator: _requiredDropdown,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // เขต/อำเภอ
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('อำเภอ/เขต', required: true),
                              DropdownButtonFormField<String>(
                                value: _district,
                                isExpanded: true,
                                items: districts
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _district = v;
                                    _subDistrict = null;
                                  });
                                },
                                decoration: _dropdownDecoration('กรุณาเลือก'),
                                validator: _requiredDropdown,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // แขวง/ตำบล + รหัสไปรษณีย์
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Label('ตำบล/แขวง', required: true),
                                    DropdownButtonFormField<String>(
                                      value: _subDistrict,
                                      isExpanded: true,
                                      items: subDistricts
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _subDistrict = v),
                                      decoration:
                                          _dropdownDecoration('กรุณาเลือก'),
                                      validator: _requiredDropdown,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'รหัสไปรษณีย์',
                                  requiredMark: true,
                                  hintText: 'รหัสไปรษณีย์',
                                  controller: _addrPostcode,
                                  keyboardType: TextInputType.number,
                                  validator: _requiredText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // -------ข้อมูลอาชีพ-------
                    _CardSection(
                      title: 'ข้อมูลอาชีพ',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('ประเภทผู้สมัคร', required: true),
                          DropdownButtonFormField<String>(
                            value: _caregiverType,
                            isExpanded: true,
                            items: _caregiverTypes
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _caregiverType = v),
                            decoration: _dropdownDecoration('กรุณาเลือก'),
                            validator: _requiredDropdown,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'เลขใบประกอบวิชาชีพ',
                            requiredMark: true,
                            hintText: 'กรอกเลขใบประกอบวิชาชีพ',
                            controller: _licenseNo,
                            validator: _requiredText,
                          ),
                          const SizedBox(height: 12),
                          const _Label('ใบรับรอง', required: true),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEDED),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _uploadedFileName ?? 'ยังไม่ได้เลือกไฟล์',
                                    style: const TextStyle(
                                      color: Color(0xFF7A7A7A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: _pickFile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      shape: const StadiumBorder(),
                                    ),
                                    child: const Text('อัพโหลด'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    PrimaryButton(
                      text: 'บันทึก',
                      loading: _loading,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ======= mini models (ไม่ชนกับของเดิมในโปรเจกต์คุณ) =======
class DistrictMini {
  final String id;
  final String nameTh;
  DistrictMini({required this.id, required this.nameTh});
}

class SubdistrictMini {
  final String districtId;
  final String nameTh;
  SubdistrictMini({required this.districtId, required this.nameTh});
}

// ======= UI helpers =======
class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}