import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class EmptyStateWidget extends StatelessWidget {
  final String svgPath;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.svgPath,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXL.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG illustration
            SvgPicture.asset(
              svgPath,
              width: 200.w,
              height: 160.h,
            ),
            SizedBox(height: AppSizes.paddingLG.h),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
              ),
            ),
            SizedBox(height: AppSizes.paddingSM.h),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                height: 1.5,
              ),
            ),
            
            // Action button (optional)
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: AppSizes.paddingXL.h),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXL.w,
                    vertical: AppSizes.paddingMD.h,
                  ),
                ),
                child: Text(
                  actionText!,
                  style: TextStyle(
                    fontSize: AppSizes.fontMD.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
