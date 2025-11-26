import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CallBlockOverlay extends StatelessWidget {
  const CallBlockOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phone icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.error,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.phone_disabled_rounded,
                        size: 60.sp,
                        color: AppColors.error,
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Loop animation
                },
              ),
              
              SizedBox(height: 40.h),
              
              // Warning icon
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.amber,
                  size: 40.sp,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Title
              Text(
                'Call Event Aniqlandi',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Qo\'ng\'iroq faol paytida xavfsizlik sabablari uchun ilovadan foydalanish cheklangan',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Animated pulse effect
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: (1 - value).clamp(0.3, 1.0),
                    child: Container(
                      width: 200.w,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 24.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: AppColors.error.withOpacity(value),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.block_rounded,
                            color: AppColors.error,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Bloklangan',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Loop animation
                },
              ),
              
              SizedBox(height: 60.h),
              
              // Info text
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white60,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Qo\'ng\'iroq tugagandan keyin ilova avtomatik qayta ishlaydi',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
