import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
// จุดบอกหน้า ใช้ในหน้า Onboarding
class OnboardingIndicator extends StatelessWidget {
  final int activeIndex;
  final int total;
  final double width;
  final double height;
  final double gap;

  const OnboardingIndicator({
    super.key,
    required this.activeIndex,
    this.total = 3, // ✅ default = 3
    this.width = 75,
    this.height = 6,
    this.gap = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == activeIndex;

        return Padding(
          padding: EdgeInsets.only(right: i == total - 1 ? 0 : gap),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.pageIndicatorActive
                  : AppColors.white,
              borderRadius: BorderRadius.circular(3),
              border: isActive
                  ? null
                  : Border.all(
                      color: AppColors.pageIndicatorActive,
                      width: 1.5,
                    ),
            ),
          ),
        );
      }),
    );
  }
}
