import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/custom_icon.dart';

/// Standard app back button — circular white pill with `CustomIcon('back')`.
/// Matches the back button used in the product category page.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardBackgroundDark
              : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: CustomIcon(
          name: 'back',
          size: 20,
          color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
        ),
      ),
    );
  }
}


