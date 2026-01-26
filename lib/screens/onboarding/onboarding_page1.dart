import 'package:flutter/material.dart';
import 'package:buddycare/theme/app_colors.dart';
import 'package:buddycare/widgets/onboarding/onboarding_indicator.dart';
import 'package:buddycare/widgets/onboarding/onboarding_next_button.dart';
import 'onboarding_page2.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- Hero Stack (ยังไม่แยกก็ได้) ---
            Center(
              child: SizedBox(
                width: 300,
                height: 350,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icons_car.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 70,
                      left: 60,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/message-1.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      right: 70,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-star.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      right: 30,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/message-2.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      left: 10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-fireworks.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --- Text ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'บริการรับ-ส่งและดูแลถึงมือหมอ\nอย่างใกล้ชิด',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'หมดกังวลเรื่องการเดินทางไปโรงพยาบาล\nเราพร้อมดูแลคนที่คุณรักตั้งแต่ออกจากบ้าน\nอำนวยความสะดวกทุกขั้นตอนที่โรงพยาบาล\nจนกลับถึงบ้านอย่างปลอดภัย',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 45),

            // --- Indicator (ใช้ซ้ำ) ---
            Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: const OnboardingIndicator(activeIndex: 0),
            ),

            const SizedBox(height: 40),

            // --- Next Button (ใช้ซ้ำ) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OnboardingNextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingPage2()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
