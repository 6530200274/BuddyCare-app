import 'package:flutter/material.dart';
import 'package:my_app/theme/app_colors.dart';

// เส้นกั้นสำหรับหน้าล็อกอินและลงทะเบียน
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.darkGrey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'หรือ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.darkGrey,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}