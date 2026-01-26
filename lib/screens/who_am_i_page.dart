import 'package:flutter/material.dart';
import 'package:my_app/screens/caregiver_login_screen.dart';
import 'package:my_app/screens/login_customer.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/widgets/login/role_button.dart';

class WhoAmIPage  extends StatelessWidget {
  const WhoAmIPage ({super.key});

  @override
  Widget build(BuildContext context) {
    // ปรับสีให้ใกล้ภาพ (ส้ม)

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Positioned(
                      bottom: 0,  //ปรับขึ้น
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo_orange.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ),

                const SizedBox(height: 26),

                const Text(
                  'ฉันคือใคร',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 26),

                // ปุ่มผู้รับบริการ
                RoleButton (
                  label: 'ผู้รับบริการ',
                  imagePath: 'assets/images/icon_heart.png',
                  color: AppColors.pageIndicatorActive,
                  width: 280,
                  height: 48,
                  fontSize: 14,
                  iconSize: 18,
                  borderRadius: 25,
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Loginuser() ),
                  );
                },
              ),

                const SizedBox(height: 14),

                // ปุ่มผู้ดูแล
                RoleButton (
                  label: 'ผู้ดูแล',
                  imagePath: 'assets/images/icon_person.png',
                  color: AppColors.pageIndicatorActive,
                  width: 280,
                  height: 48,
                  fontSize: 14,
                  iconSize: 18,
                  borderRadius: 25,
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CaregiverLoginScreen() ),
                  );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


