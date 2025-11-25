import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_sizes.dart';
import 'package:gold_mobile/core/constants/app_strings.dart';
import 'package:gold_mobile/core/utils/toast_helper.dart';
import 'package:gold_mobile/core/widgets/loading_widget.dart';
import 'package:gold_mobile/core/widgets/custom_icon.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:pinput/pinput.dart';

class OtpVerifyPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerifyPage({super.key, required this.phoneNumber});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  
  // Timer variables
  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 120;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _maskPhoneNumber(String phone) {
    // Format: +998 ** *** 12 34
    if (phone.length >= 12) {
      final last4 = phone.substring(phone.length - 4);
      final last2 = last4.substring(0, 2);
      final last2Final = last4.substring(2);
      return '+998 ** *** $last2 $last2Final';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: isDark ? AppColors.textDarkOnDark : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.surface,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
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
        color: isDark 
            ? AppColors.gold.withOpacity(0.15)
            : AppColors.primaryLight.withOpacity(0.1),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackgroundDark : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: CustomIcon(
              name: 'back',
              size: 20,
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ToastHelper.showError(state.message);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingLG.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.paddingXL.h),
                // Title
                Text(
                  AppStrings.verifyOTP,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: AppSizes.paddingSM.h),
                // Subtitle with masked phone
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    children: [
                      const TextSpan(text: 'Telefon raqamingizga yuborilgan\n'),
                      TextSpan(
                        text: _maskPhoneNumber(widget.phoneNumber),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '\n6 raqamli kodni kiriting'),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.paddingXL.h),
                // OTP Input
                Center(
                  child: Pinput(
                    controller: _pinController,
                    focusNode: _focusNode,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    showCursor: true,
                    onCompleted: (pin) {
                      context.read<AuthBloc>().add(
                            VerifyOtpRequested(pin, widget.phoneNumber),
                          );
                    },
                  ),
                ),
                SizedBox(height: AppSizes.paddingLG.h),
                // Timer and Resend Code
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  SendOtpRequested(widget.phoneNumber),
                                );
                            ToastHelper.showSuccess('Kod qayta yuborildi');
                            _startTimer();
                          },
                          child: const Text(AppStrings.resendCode),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMD.w,
                            vertical: AppSizes.paddingSM.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull.r),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                size: 20.sp,
                                color: AppColors.gold,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Qayta yuborish: ${_formatTime(_remainingSeconds)}',
                                style: TextStyle(
                                  fontSize: AppSizes.fontSM.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const Spacer(),
                // Verify Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return ElevatedButton(
                      onPressed: _pinController.text.length == 6 && !isLoading
                          ? () {
                              context.read<AuthBloc>().add(
                                    VerifyOtpRequested(
                                      _pinController.text,
                                      widget.phoneNumber,
                                    ),
                                  );
                            }
                          : null,
                      child: isLoading
                          ? const LoadingWidget(
                              size: 20,
                              color: AppColors.textOnPrimary,
                              strokeWidth: 2,
                            )
                          : const Text(AppStrings.verifyButton),
                    );
                  },
                ),
                SizedBox(height: AppSizes.paddingLG.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
