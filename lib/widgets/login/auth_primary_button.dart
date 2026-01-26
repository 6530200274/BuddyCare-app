import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String text;

  // ✅ ให้เป็น nullable เพื่อ disable ได้
  final VoidCallback? onPressed;

  final double height;
  final double width;

  // ✅ เพิ่ม loading
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 44,
    this.width = double.infinity,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pageIndicatorActive,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          disabledBackgroundColor: AppColors.pageIndicatorActive.withOpacity(0.6),
          disabledForegroundColor: AppColors.white.withOpacity(0.9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}