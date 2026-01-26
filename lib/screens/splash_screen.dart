import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/screens/onboarding/onboarding_page1.dart';
import '../theme/app_colors.dart';

// อย่าลืมแก้สี!!  แก้แล้วด้วยนะ


class SplashScreenSlideSmoothForward extends StatefulWidget {
  const SplashScreenSlideSmoothForward({super.key});

  @override
  State<SplashScreenSlideSmoothForward> createState() =>
      _SplashScreenSlideSmoothForwardState();
}

class _SplashScreenSlideSmoothForwardState
    extends State<SplashScreenSlideSmoothForward>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<int> _textAnimation;

  final String _text = "Buddy Care";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    // แอนิเมชันสำหรับแสดงตัวอักษรทีละตัว
    _textAnimation = IntTween(
      begin: 0,
      end: _text.length,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn), // เริ่มหลังโลโก้เลื่อนมาแล้ว
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingPage1(), //  ← เปลี่ยนเป็นหน้า OnboardingPage1
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้ - เลื่อนมา
            SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                'assets/images/logo_white.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 20),
            // ข้อความ - แสดงทีละตัว แต่ไม่เลื่อนตาม
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                String displayText = _text.substring(0, _textAnimation.value);
                return Text(
                  displayText,
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 2,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}