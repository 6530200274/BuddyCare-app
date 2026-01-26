import 'package:flutter/material.dart';
import 'package:my_app/theme/app_colors.dart';


class RoleButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final Color color;
  final VoidCallback onPressed;

  // ✅ ปรับขนาดได้
  final double height;
  final double width;

  // ✅ ปรับหน้าตาได้
  final double borderRadius;
  final double iconSize;
  final double fontSize;

  const RoleButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.color,
    required this.onPressed,

    // ✅ ค่า default ที่เหมาะกับปุ่ม
    this.height = 52,
    this.width = double.infinity,

    this.borderRadius = 28,
    this.iconSize = 22,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: iconSize,
              height: iconSize,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Icon(Icons.arrow_forward, size: iconSize),
          ],
        ),
      ),
    );
  }
}
