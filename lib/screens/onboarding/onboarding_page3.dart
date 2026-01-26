
import 'package:flutter/material.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/widgets/onboarding/onboarding_indicator.dart';
import 'package:my_app/widgets/onboarding/onboarding_next_button.dart';


class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

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

                  children: [
                    Positioned(
                      top: 110,          // ปรับขึ้น/ลงได้ตามต้องการ
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/icon-center-3.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 90,
                      left: 15,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/message-4.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 190,
                      left: 25,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-star-3.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 120,
                      right: 55,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icon-star-3.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 250,
                      right: 20,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/message-5.png'),
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
                    'เริ่มต้นดูแลสุขภาพคนที่คุณรักไปกับเรา',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'สัมผัสประสบการณ์การดูแลระดับมืออาชีพ\nที่ออกแบบมาเพื่อผู้สูงอายุโดยเฉพาะ \nลงทะเบียนวันนี้ เพื่อเตรียมพร้อมสำหรับ\nการนัดหมายครั้งสำคัญ',
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
            child: const OnboardingIndicator(activeIndex: 2),
            ),

            const SizedBox(height: 40),

            // --- Next Button (ใช้ซ้ำ) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OnboardingNextButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) =>  WhoAmIPage ()),
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WhoAmIPage {
}
