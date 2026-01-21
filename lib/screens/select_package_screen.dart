// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:my_app/screens/meeting_point_screen.dart';
import 'package:my_app/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import '../models/package_model.dart';
import '../providers/selected_package_provider.dart';

class SelectPackageScreen extends StatelessWidget {
  static const routeName = '/select-package';
  const SelectPackageScreen({super.key});

  static const _packages = <CarePackage>[
    CarePackage(
      id: 'p1',
      title: 'Package 1',
      description:
          'บริการพาไปหาหมอ พร้อมเรียกรถยนต์และผู้ดูแล + '
          'เรียกรถไปรับที่บ้านไปส่งที่รพ. + ให้บริการระหว่างอยู่รพ. และส่งกลับบ้าน',
      price: 1300,
    ),
    CarePackage(
      id: 'p2',
      title: 'Package 2',
      description:
          'บริการพาไปหาหมอ ผู้ดูแลไปเจอกับลูกค้าที่รพ. +\n'
          'ให้บริการระหว่างอยู่ที่รพ. และแยกย้ายกลับบ้าน',
      price: 1000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedId = context.watch<SelectedPackageProvider>().selected?.id;

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
          'เลือกแพ็กเกจ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HintBox(),
                    const SizedBox(height: 14),

                    ..._packages.map(
                      (pkg) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PackageCard(
                          pkg: pkg,
                          selected: selectedId == pkg.id,
                          onTap: () {
                            context.read<SelectedPackageProvider>().select(pkg);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //ปุ่มถัดไป
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: PrimaryButton(
              text: 'ถัดไป',
              onPressed: selectedId == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MeetingPointScreen(),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 6),
        Text(
          '1. ทุก Package ให้บริการสูงสุด 8 ชั่วโมง หากเกิน 8 ชั่วโมง มีค่าบริการล่วงเวลา 200 บาท/ชั่วโมง',
        ),
        Text('2. ค่าบริการนอกพื้นที่เพิ่ม 200 บาท'),
        Text('3. ค่าใช้จ่ายทั้งหมดรวมภาษีมูลค่าเพิ่มเรียบร้อยแล้ว'),
        SizedBox(height: 4),
        Text(
          '4. ผู้รับบริการต้องจองบริการก่อนการจองครั้งดูแลล่วงหน้าอย่างน้อย 1 วัน',
          style: TextStyle(color: Color(0xFFFF8A00)),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final CarePackage pkg;
  final bool selected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.pkg,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFF8A00),
            width: selected ? 2 : 1,
          ),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RadioDot(selected: selected),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.title,
                    style: const TextStyle(
                      color: Color(0xFFFF8A00),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(pkg.description),
                  const SizedBox(height: 10),
                  Text(
                    'ค่าบริการ ${pkg.price.toStringAsFixed(2)} บาท',
                    style: const TextStyle(
                      color: Color(0xFFFF8A00),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFF8A00), width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF8A00),
                ),
              ),
            )
          : null,
    );
  }
}
