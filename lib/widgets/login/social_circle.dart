import 'package:flutter/material.dart';
import 'package:my_app/theme/app_colors.dart';

class SocialCircle extends StatelessWidget {
  final Widget child;

  // ✅ nullable เพื่อ disable ได้
  final VoidCallback? onPressed;

  const SocialCircle({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: onPressed == null
              ? AppColors.orangfour
              : AppColors.orangfour,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}