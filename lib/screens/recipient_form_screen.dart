import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/providers/recipient_provider.dart';
import 'package:my_app/screens/questionnaire_screen.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../models/recipient_profile.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class RecipientFormScreen extends StatefulWidget {
  const RecipientFormScreen({super.key});

  @override
  State<RecipientFormScreen> createState() => _RecipientFormScreenState();
}

class _RecipientFormScreenState extends State<RecipientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers - ผู้รับบริการ
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _dobText = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();

  // Controllers - ฉุกเฉิน
  final _emgFirstName = TextEditingController();
  final _emgLastName = TextEditingController();
  final _emgPhone = TextEditingController();

  DateTime? _dob;

  // Dropdown values
  String? _nationality;
  String? _religion;
  String? _language;
  String? _gender;
  String? _relationship;

  bool _loading = false;

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
  final _languages = const ['ไทย', 'อังกฤษ'];
  final _genders = const ['เพศชาย', 'เพศหญิง', 'ไม่ระบุ'];
  final _relationships = const [
    'ตัวฉันเอง',
    'บุตร',
    'บิดาหรือมารดา',
    'สามีหรือภรรยา',
    'พี่หรือน้อง',
    'ปู่ย่าหรือตายาย',
    'ลุงป้าหรือน้าอา',
    'ญาติ',
    'บุคคลในอุปการะตามกฎหมาย',
  ];

  @override
  void initState() {
    super.initState();

    // Prefill จาก Provider 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<RecipientProvider>().profile;
      if (p == null) return;

      setState(() {
        _firstName.text = p.firstName;
        _lastName.text = p.lastName;
        _phone.text = p.phone;

        _dob = p.dob;
        _dobText.text =
            p.dob == null ? '' : DateFormat('dd/MM/yyyy').format(p.dob!);

        _nationality = p.nationality.isEmpty ? null : p.nationality;
        _religion = p.religion.isEmpty ? null : p.religion;
        _language = p.language.isEmpty ? null : p.language;
        _gender = p.gender.isEmpty ? null : p.gender;
        _relationship = p.relationship.isEmpty ? null : p.relationship;

        _weight.text = p.weightKg?.toString() ?? '';
        _height.text = p.heightCm?.toString() ?? '';

        _emgFirstName.text = p.emergencyContact.firstName;
        _emgLastName.text = p.emergencyContact.lastName;
        _emgPhone.text = p.emergencyContact.phone;
      });
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _dobText.dispose();
    _weight.dispose();
    _height.dispose();
    _emgFirstName.dispose();
    _emgLastName.dispose();
    _emgPhone.dispose();
    super.dispose();
  }

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
    if (digits.length < 9 || digits.length > 10) return 'รูปแบบเบอร์โทรไม่ถูกต้อง';
    return null;
  }

  double? _parseNullableDouble(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 30, now.month, now.day);
    final orangeColor = AppColors.primary;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: orangeColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: orangeColor),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
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

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    try {
      final profile = RecipientProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim(),
        dob: _dob,
        nationality: (_nationality ?? '').trim(),
        religion: (_religion ?? '').trim(),
        language: (_language ?? '').trim(),
        weightKg: _parseNullableDouble(_weight.text),
        heightCm: _parseNullableDouble(_height.text),
        gender: (_gender ?? '').trim(),
        relationship: (_relationship ?? '').trim(),
        emergencyContact: EmergencyContact(
          firstName: _emgFirstName.text.trim(),
          lastName: _emgLastName.text.trim(),
          phone: _emgPhone.text.trim(),
        ),
      );

      // บันทึกลง Provider 
      context.read<RecipientProvider>().setProfile(profile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ADLScreeningPage()),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFFFA726),
            child: Center(
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
        ),
        centerTitle: true,
        title: const Text(
          'ผู้รับบริการ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _CardSection(
                title: 'ข้อมูลผู้รับบริการ',
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
                            validator: (v) =>
                                _dob == null ? 'กรุณาเลือกวันเกิด' : null,
                            suffixIcon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('สัญชาติ', required: true),
                              DropdownButtonFormField<String>(
                                key: ValueKey(_nationality),
                                initialValue: _nationality,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.text),
                                iconEnabledColor: AppColors.textSecondary,
                                dropdownColor: Colors.white,
                                items: _nationalities
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _nationality = v),
                                decoration: _dropdownDecoration('กรุณาเลือก'),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('ศาสนา'),
                              DropdownButtonFormField<String>(
                                key: ValueKey(_religion),
                                initialValue: _religion,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.text),
                                iconEnabledColor: AppColors.textSecondary,
                                dropdownColor: Colors.white,
                                items: _religions
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _religion = v),
                                decoration: _dropdownDecoration('กรุณาเลือก'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('ภาษาหลักที่ใช้สื่อสาร'),
                              DropdownButtonFormField<String>(
                                key: ValueKey(_language),
                                initialValue: _language,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.text),
                                iconEnabledColor: AppColors.textSecondary,
                                dropdownColor: Colors.white,
                                items: _languages
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _language = v),
                                decoration: _dropdownDecoration('กรุณาเลือก'),
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
                            label: 'น้ำหนัก',
                            requiredMark: true,
                            hintText: 'กรอกน้ำหนัก',
                            controller: _weight,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            validator: _requiredText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'ส่วนสูง',
                            requiredMark: true,
                            hintText: 'กรอกส่วนสูง',
                            controller: _height,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            validator: _requiredText,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('เพศ', required: true),
                              DropdownButtonFormField<String>(
                                key: ValueKey(_gender),
                                initialValue: _gender,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.text),
                                iconEnabledColor: AppColors.textSecondary,
                                dropdownColor: Colors.white,
                                items: _genders
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _gender = v),
                                decoration: _dropdownDecoration('กรุณาเลือก'),
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
                              const _Label('ความสัมพันธ์', required: true),
                              DropdownButtonFormField<String>(
                                key: ValueKey(_relationship),
                                initialValue: _relationship,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.text),
                                iconEnabledColor: AppColors.textSecondary,
                                dropdownColor: Colors.white,
                                items: _relationships.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _relationship = v),
                                decoration: _dropdownDecoration('กรุณาเลือก'),
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
              _CardSection(
                title: 'ผู้ติดต่อกรณีฉุกเฉิน',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'ชื่อ',
                      requiredMark: true,
                      hintText: 'กรอกชื่อ',
                      controller: _emgFirstName,
                      validator: _requiredText,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'นามสกุล',
                      requiredMark: true,
                      hintText: 'กรอกนามสกุล',
                      controller: _emgLastName,
                      validator: _requiredText,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'เบอร์โทรศัพท์',
                      requiredMark: true,
                      hintText: 'กรอกเบอร์โทรศัพท์',
                      controller: _emgPhone,
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
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
            Text(title, style: Theme.of(context).textTheme.titleMedium),
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFFF6701),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
