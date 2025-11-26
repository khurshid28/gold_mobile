import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class PinVerificationBottomSheet extends StatefulWidget {
  final bool isDark;
  final VoidCallback onVerified;
  final String? title;

  const PinVerificationBottomSheet({
    super.key,
    required this.isDark,
    required this.onVerified,
    this.title,
  });

  @override
  State<PinVerificationBottomSheet> createState() =>
      _PinVerificationBottomSheetState();
}

class _PinVerificationBottomSheetState
    extends State<PinVerificationBottomSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isVerifying = false;
  int _remainingSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 60;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _resendCode() async {
    if (!_canResend) return;

    // TODO: Call API to resend code
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kod qayta yuborildi'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    _startTimer();
  }

  void _verifyPin() async {
    if (_pinController.text.length == 6) {
      setState(() {
        _isVerifying = true;
      });

      // Simulate verification
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        widget.onVerified();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: widget.isDark ? AppColors.textDarkOnDark : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.cardBackgroundDark : AppColors.surface,
        border: Border.all(
          color: widget.isDark ? AppColors.borderDark : AppColors.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: widget.isDark
            ? AppColors.gold.withOpacity(0.15)
            : AppColors.primaryLight.withOpacity(0.1),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
    );

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: 24.h),

            // Icon
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                color: AppColors.gold,
                size: 35.sp,
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              widget.title ?? 'Tasdiqlash kodi',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: widget.isDark
                    ? AppColors.textDarkOnDark
                    : AppColors.textDark,
              ),
            ),

            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'Telefon raqamingizga yuborilgan\n6 raqamli kodni kiriting',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: widget.isDark
                    ? AppColors.textMediumOnDark
                    : AppColors.textMedium,
              ),
            ),

            SizedBox(height: 32.h),

            // PIN Input
            Pinput(
              controller: _pinController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              showCursor: true,
              enabled: !_isVerifying,
              onCompleted: (pin) {
                _verifyPin();
              },
            ),

            SizedBox(height: 20.h),

            // Timer and Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_canResend) ...[
                  Icon(
                    Icons.timer_outlined,
                    size: 18.sp,
                    color: AppColors.gold,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${_remainingSeconds}s',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: _resendCode,
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Kodni qayta yuborish',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 20.h),

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying || _pinController.text.length != 6
                    ? null
                    : _verifyPin,
                child: _isVerifying
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textOnPrimary,
                          ),
                        ),
                      )
                    : const Text('Tasdiqlash'),
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
