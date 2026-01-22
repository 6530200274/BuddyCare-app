import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/providers/questionnaire_provider.dart';
import 'package:my_app/screens/recipient_form_screen.dart';
import 'package:my_app/screens/select_package_screen.dart';
import 'package:provider/provider.dart';

class ADLScreeningPage extends StatefulWidget {
  const ADLScreeningPage({super.key});

  @override
  State<ADLScreeningPage> createState() => _ADLScreeningPageState();
}

class _ADLScreeningPageState extends State<ADLScreeningPage> {
  final List<_AdlItem> _items = const [
    _AdlItem(no: 1, title: "การกินอาหาร", maxScore: 10),
    _AdlItem(no: 2, title: "การเคลื่อนย้าย (จากเตียงไปเก้าอี้)", maxScore: 15),
    _AdlItem(no: 3, title: "การดูแลสุขอนามัยส่วนตัว", maxScore: 5),
    _AdlItem(no: 4, title: "การใช้ห้องน้ำ", maxScore: 10),
    _AdlItem(no: 5, title: "การอาบน้ำ", maxScore: 5),
    _AdlItem(no: 6, title: "การเดิน", maxScore: 15),
    _AdlItem(no: 7, title: "การขึ้นลงบันได", maxScore: 10),
    _AdlItem(no: 8, title: "การแต่งตัว", maxScore: 10),
    _AdlItem(no: 9, title: "การควบคุมการขับถ่ายปัสสาวะ", maxScore: 10),
    _AdlItem(no: 10, title: "การควบคุมการขับถ่ายอุจจาระ", maxScore: 10),
  ];

  late final List<TextEditingController> _controllers = List.generate(
    _items.length,
    (_) => TextEditingController(),
  );

  late final List<FocusNode> _focusNodes = List.generate(
    _items.length,
    (_) => FocusNode(),
  );

  late final List<String?> _errors = List<String?>.filled(_items.length, null);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  int _parseScore(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return 0;
    final v = int.tryParse(trimmed);
    return v ?? 0;
  }

  // ตรวจว่าเกินคะแนนเต็มไหม แล้วแสดง error
  void _validateScore(int index) {
    final item = _items[index];
    final text = _controllers[index].text.trim();

    if (text.isEmpty) {
      _errors[index] = null;
      setState(() {});
      return;
    }

    final value = int.tryParse(text);

    if (value == null) {
      _errors[index] = "กรุณากรอกตัวเลข";
    } else if (value < 0) {
      _errors[index] = "กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป";
    } else if (value > item.maxScore) {
      _errors[index] = "กรอกได้ไม่เกิน ${item.maxScore} คะแนน";
    } else {
      _errors[index] = null;
    }

    setState(() {});
  }

  int get _totalScore {
    int sum = 0;
    for (int i = 0; i < _items.length; i++) {
      final raw = _parseScore(_controllers[i].text);
      if (_errors[i] != null) continue;
      sum += raw.clamp(0, _items[i].maxScore);
    }
    return sum;
  }

  int get _maxTotalScore => _items.fold(0, (p, e) => p + e.maxScore); // =100

  String get _matchedCaregiverType {
    final score = _totalScore;
    if (score <= 20) return "พยาบาลวิชาชีพ";
    if (score <= 60) return "ผู้ช่วยพยาบาล";
    return "ผู้ดูแลทั่วไป"; // 61–100
  }

  bool get _allFilled => _controllers.every((c) => c.text.trim().isNotEmpty);

  bool get _hasAnyError => _errors.any((e) => e != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                      builder: (_) => const RecipientFormScreen(),
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
        title: const Text(
          'แบบสอบถามคัดกรอง',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "การประเมินความสามารถในการทำกิจวัตรประจำวันของผู้สูงอายุ (ADL)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "ให้คะแนนทำกิจกรรมต่อไปนี้ได้ด้วยตนเอง",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      for (int i = 0; i < _items.length; i++) ...[
                        _AdlInputRow(
                          item: _items[i],
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          errorText: _errors[i],
                          onChanged: (_) => _validateScore(i),
                          onEditingComplete: () {
                            _validateScore(i);
                            if (i < _focusNodes.length - 1) {
                              _focusNodes[i + 1].requestFocus();
                            } else {
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                        if (i != _items.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFFFF6ED),
                border: Border.all(color: const Color(0xFFFFD7B2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "รวมคะแนน: $_totalScore / $_maxTotalScore",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "ผลการแมทช์ผู้ดูแล: $_matchedCaregiverType",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "เกณฑ์การแมทช์:\n"
                    "• 0–20  → พยาบาลวิชาชีพ\n"
                    "• 21–60 → ผู้ช่วยพยาบาล\n"
                    "• 61–100 → ผู้ดูแลทั่วไป",
                    style: TextStyle(fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (_allFilled && !_hasAnyError)
                    ? () {
                        final scores = List<int>.generate(
                          _items.length,
                          (i) => _parseScore(
                            _controllers[i].text,
                          ).clamp(0, _items[i].maxScore),
                        );
                        final result = ADLResult(
                          scores: scores,
                          totalScore: _totalScore,
                          caregiverType: _matchedCaregiverType,
                        );
                        // เก็บลง Provider
                        context.read<ADLProvider>().setResult(result);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SelectPackageScreen(),
                          ),
                        );
                      }
                    : null,

                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text("บันทึก"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdlInputRow extends StatelessWidget {
  const _AdlInputRow({
    required this.item,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onEditingComplete,
    required this.errorText,
  });

  final _AdlItem item;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "${item.no}. ${item.title}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              "เต็ม ${item.maxScore} คะแนน",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textInputAction: item.no == 10
              ? TextInputAction.done
              : TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: "กรุณากรอกตัวเลข",
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 11, color: Colors.red),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFFBDBDBD),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 1.5,
                color: hasError ? Colors.red : Theme.of(context).primaryColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
        ),
      ],
    );
  }
}

class _AdlItem {
  final int no;
  final String title;
  final int maxScore;

  const _AdlItem({
    required this.no,
    required this.title,
    required this.maxScore,
  });
}
