
import 'package:flutter/material.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/widgets/onboarding/onboarding_indicator.dart';
import 'package:my_app/widgets/onboarding/onboarding_next_button.dart';
import 'onboarding_page3.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

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
                      //top: 70,
                      left: 30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-iphone.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 110,
                      left: 25,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-wifi.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 110,
                      right: 45,
                      child: Container(
                        width: 145,
                        height: 145,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/message-3.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 220,
                      right: 60,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-star-2.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 265,
                      right: 65,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-like.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Text ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รู้ใจได้ ด้วยผู้ดูแลมืออาชีพ\nอย่างใกล้ชิด',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ไม่ว่าคุณจะอยู่ที่ไหนผู้ดูแลมืออาชีพของเรา\nพร้อมดูแลอย่างใกล้ชิดด้วยประสบการณ์และ\nความใส่ใจในการดูแลอย่างถูกต้องเพื่อให้คุณ\nและคนที่คุณรักอุ่นใจในทุกช่วงเวลา',
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
            child: const OnboardingIndicator(activeIndex: 1),
            ),

            const SizedBox(height: 40),

            // --- Next Button (ใช้ซ้ำ) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OnboardingNextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingPage3()),
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
