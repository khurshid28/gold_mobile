import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'custom_icon.dart';

class PageNotFoundWidget extends StatelessWidget {
  const PageNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Back button at top
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomIcon(
                        name: 'back',
                        size: 24,
                        color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 404 Icon/Image
                Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIcon(
                          name: 'search_empty',
                          size: 80,
                          color: AppColors.gold,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '404',
                          style: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Text(
                  'Sahifa topilmadi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                  ),
                ),

                SizedBox(height: 12.h),

                // Description
                Text(
                  'Kechirasiz, siz qidirayotgan sahifa mavjud emas yoki ko\'chirilgan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 40.h),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Go back button
                    if (context.canPop())
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.pop(),
                          icon: CustomIcon(name: 'back', size: 20),
                          label: Text(
                            'Orqaga',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                        ),
                      ),
                    
                    if (context.canPop()) SizedBox(width: 12.w),
                    
                    // Home button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: CustomIcon(name: 'home_icon', size: 20),
                        label: Text(
                          'Bosh sahifa',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
