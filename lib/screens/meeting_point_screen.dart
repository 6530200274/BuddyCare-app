import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_app/screens/select_datetime_screen.dart';
import 'package:my_app/screens/select_package_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../models/location_models.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_point_provider.dart';

class MeetingPointScreen extends StatefulWidget {
  const MeetingPointScreen({super.key});

  @override
  State<MeetingPointScreen> createState() => _MeetingPointScreenState();
}

class _MeetingPointScreenState extends State<MeetingPointScreen> {
  final _formKey = GlobalKey<FormState>();

  // จุดนัดพบ
  final _placeName = TextEditingController();
  final _address = TextEditingController();
  final _postcode = TextEditingController();

  // search text fields
  final _hospitalText = TextEditingController();
  final _districtText = TextEditingController();
  final _subdistrictText = TextEditingController();

  // dropdown values
  String? _province; // จังหวัด (ชื่อ)
  String? _districtId; // เขต (id)
  String? _subdistrictId; // แขวง (id)

  // จุดหมาย
  String? _destProvince; // จังหวัดของโรงพยาบาล
  String? _hospitalId;

  // data from json
  List<ProvinceHospitals> _provinceHospitals = [];
  List<District> _bkkDistricts = [];
  List<Subdistrict> _bkkSubdistricts = [];

  // derived lists
  List<String> get _provinceNames =>
      _provinceHospitals.map((e) => e.provinceName).toList();

  List<Hospital> get _hospitalsOfSelectedDestProvince {
    final p = _provinceHospitals.where((e) => e.provinceName == _destProvince);
    if (p.isEmpty) return [];
    return p.first.hospitals;
  }

  List<Subdistrict> get _subdistrictsOfSelectedDistrict {
    if (_districtId == null) return [];
    return _bkkSubdistricts.where((s) => s.districtId == _districtId).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    final hospitalsStr = await rootBundle.loadString('assets/hospitals.json');
    final hospitalsJson = jsonDecode(hospitalsStr) as Map<String, dynamic>;
    final provinces = (hospitalsJson['provinces'] as List<dynamic>)
        .map((e) => ProvinceHospitals.fromJson(e))
        .toList();

    final bkkStr = await rootBundle.loadString(
      'assets/bkk_master_district_subdistrict.json',
    );
    final bkkJson = jsonDecode(bkkStr) as Map<String, dynamic>;
    final districts = (bkkJson['districts'] as List<dynamic>)
        .map((e) => District.fromJson(e))
        .toList();
    final subdistricts = (bkkJson['subdistricts'] as List<dynamic>)
        .map((e) => Subdistrict.fromJson(e))
        .toList();

    if (!mounted) return;
    setState(() {
      _provinceHospitals = provinces;
      _bkkDistricts = districts;
      _bkkSubdistricts = subdistricts;

      // default
      _province = 'กรุงเทพมหานคร';
      _destProvince = 'กรุงเทพมหานคร';
    });
  }

  Future<void> _pickDistrict() async {
    FocusScope.of(context).unfocus();

    if (_province != 'กรุงเทพมหานคร') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รองรับเฉพาะกรุงเทพมหานคร')));
      return;
    }

    final picked = await showSearch<District?>(
      context: context,
      delegate: _DistrictSearchDelegate(_bkkDistricts),
    );

    if (picked == null) return;

    setState(() {
      _districtId = picked.id;
      _districtText.text = picked.nameTh;

      // reset dependents
      _subdistrictId = null;
      _subdistrictText.clear();
      _postcode.clear();
    });
  }

  Future<void> _pickSubdistrict() async {
    FocusScope.of(context).unfocus();

    if (_province != 'กรุงเทพมหานคร') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รองรับเฉพาะกรุงเทพมหานคร')));
      return;
    }
    if (_districtId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกเขตก่อน')));
      return;
    }

    final list = _subdistrictsOfSelectedDistrict;
    final picked = await showSearch<Subdistrict?>(
      context: context,
      delegate: _SubdistrictSearchDelegate(list),
    );

    if (picked == null) return;

    setState(() {
      _subdistrictId = picked.id;
      _subdistrictText.text = picked.nameTh;
    });
  }

  Future<void> _pickHospital() async {
    FocusScope.of(context).unfocus();

    final list = _hospitalsOfSelectedDestProvince;
    if (_destProvince == null || list.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกจังหวัดก่อน')));
      return;
    }

    final picked = await showSearch<Hospital?>(
      context: context,
      delegate: _HospitalSearchDelegate(list),
    );

    if (picked == null) return;

    setState(() {
      _hospitalId = picked.id;
      _hospitalText.text = picked.name;
    });
  }

  @override
  void dispose() {
    _placeName.dispose();
    _address.dispose();
    _postcode.dispose();
    _hospitalText.dispose();
    _districtText.dispose();
    _subdistrictText.dispose();
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
    final isReady = _provinceHospitals.isNotEmpty && _bkkDistricts.isNotEmpty;

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
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectPackageScreen(),
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
          'เลือกจุดนัดพบ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: Colors.white,
      body: !isReady
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _CardSection(
                      title: 'จุดนัดพบ',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'ที่อยู่',
                            requiredMark: true,
                            hintText: 'กรอกที่อยู่',
                            controller: _address,
                            validator: _requiredText,
                          ),
                          const SizedBox(height: 12),

                          // จังหวัด / เขต
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Label('จังหวัด', required: true),
                                    DropdownButtonFormField<String>(
                                      key: ValueKey(_province),
                                      initialValue: _province,
                                      isExpanded: true,
                                      items: _provinceNames
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p,
                                              child: Text(p),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          _province = v;

                                          // reset เขต/แขวง/รหัสไปรษณีย์ เมื่อเปลี่ยนจังหวัด
                                          _districtId = null;
                                          _districtText.clear();
                                          _subdistrictId = null;
                                          _subdistrictText.clear();
                                          _postcode.clear();
                                        });
                                      },
                                      decoration: _dropdownDecoration(
                                        'กรุณาเลือก',
                                      ),
                                      validator: _requiredDropdown,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // เขต (ค้นหาได้)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Label('อำเภอ/เขต', required: true),
                                    TextFormField(
                                      controller: _districtText,
                                      readOnly: true,
                                      onTap: _pickDistrict,
                                      decoration:
                                          _dropdownDecoration(
                                            _province == 'กรุงเทพมหานคร'
                                                ? 'แตะเพื่อค้นหา'
                                                : 'รองรับเฉพาะ กทม.',
                                          ).copyWith(
                                            suffixIcon: const Icon(
                                              Icons.search,
                                            ),
                                          ),
                                      validator: (_) {
                                        if (_province == 'กรุงเทพมหานคร') {
                                          return _requiredDropdown(_districtId);
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // แขวง / รหัสไปรษณีย์
                          Row(
                            children: [
                              // แขวง (ค้นหาได้)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Label('ตำบล/แขวง', required: true),
                                    TextFormField(
                                      controller: _subdistrictText,
                                      readOnly: true,
                                      onTap: _pickSubdistrict,
                                      decoration:
                                          _dropdownDecoration(
                                            (_province == 'กรุงเทพมหานคร' &&
                                                    _districtId != null)
                                                ? 'แตะเพื่อค้นหา'
                                                : 'เลือกเขตก่อน',
                                          ).copyWith(
                                            suffixIcon: const Icon(
                                              Icons.search,
                                            ),
                                          ),
                                      validator: (_) {
                                        if (_province == 'กรุงเทพมหานคร') {
                                          return _requiredDropdown(
                                            _subdistrictId,
                                          );
                                        }
                                        return null;
                                      },
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
                                  controller: _postcode,
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

                    _CardSection(
                      title: 'จุดหมาย',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('จังหวัด', required: true),
                          DropdownButtonFormField<String>(
                            key: ValueKey(_destProvince),
                            initialValue: _destProvince,
                            isExpanded: true,
                            items: _provinceNames
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _destProvince = v;
                                _hospitalId = null;
                                _hospitalText.clear();
                              });
                            },
                            decoration: _dropdownDecoration('กรุณาเลือก'),
                            validator: _requiredDropdown,
                          ),

                          const SizedBox(height: 12),

                          const _Label('โรงพยาบาล', required: true),

                          // โรงพยาบาล (ค้นหาได้)
                          TextFormField(
                            controller: _hospitalText,
                            readOnly: true,
                            onTap: _pickHospital,
                            decoration: _dropdownDecoration(
                              'แตะเพื่อค้นหา',
                            ).copyWith(suffixIcon: const Icon(Icons.search)),
                            validator: (_) => _requiredDropdown(_hospitalId),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: 'บันทึก',
                      onPressed: () {
                        final ok = _formKey.currentState?.validate() ?? false;
                        if (!ok) return;
                        if (_province == null ||
                            _districtId == null ||
                            _subdistrictId == null ||
                            _destProvince == null ||
                            _hospitalId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('กรุณากรอกข้อมูลให้ครบ'),
                            ),
                          );
                          return;
                        }

                        final meetingPoint = MeetingPointData(
                          address: _address.text.trim(),
                          province: _province!.trim(),
                          districtId: _districtId!.trim(),
                          districtName: _districtText.text.trim(),
                          subdistrictId: _subdistrictId!.trim(),
                          subdistrictName: _subdistrictText.text.trim(),
                          postcode: _postcode.text.trim(),
                          destProvince: _destProvince!.trim(),
                          hospitalId: _hospitalId!.trim(),
                          hospitalName: _hospitalText.text.trim(),
                        );

                        //เก็บลง Provider
                        context.read<MeetingPointProvider>().setData(
                          meetingPoint,
                        );
                        // ไปหน้าถัดไป
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SelectDateTimeScreen(),
                          ),
                        );
                      },
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

class _DistrictSearchDelegate extends SearchDelegate<District?> {
  _DistrictSearchDelegate(this.items);
  final List<District> items;

  @override
  String get searchFieldLabel => 'ค้นหาเขต';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) {
    return _orangeBackCircleButton(context, () => close(context, null));
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((d) => d.nameTh.toLowerCase().contains(q)).toList();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final d = filtered[i];
        return ListTile(title: Text(d.nameTh), onTap: () => close(context, d));
      },
    );
  }
}

class _SubdistrictSearchDelegate extends SearchDelegate<Subdistrict?> {
  _SubdistrictSearchDelegate(this.items);
  final List<Subdistrict> items;

  @override
  String get searchFieldLabel => 'ค้นหาแขวง';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) {
    return _orangeBackCircleButton(context, () => close(context, null));
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((s) => s.nameTh.toLowerCase().contains(q)).toList();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = filtered[i];
        return ListTile(title: Text(s.nameTh), onTap: () => close(context, s));
      },
    );
  }
}

class _HospitalSearchDelegate extends SearchDelegate<Hospital?> {
  _HospitalSearchDelegate(this.items);
  final List<Hospital> items;

  @override
  String get searchFieldLabel => 'ค้นหาโรงพยาบาล';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) {
    return _orangeBackCircleButton(context, () => close(context, null));
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((h) => h.name.toLowerCase().contains(q)).toList();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final h = filtered[i];
        return ListTile(title: Text(h.name), onTap: () => close(context, h));
      },
    );
  }
}

Widget _orangeBackCircleButton(BuildContext context, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: CircleAvatar(
      backgroundColor: const Color(0xFFFFA726),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Center(
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
    ),
  );
}
