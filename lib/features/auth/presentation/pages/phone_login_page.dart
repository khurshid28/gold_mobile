import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_mobile/core/constants/app_assets.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_sizes.dart';
import 'package:gold_mobile/core/constants/app_strings.dart';
import 'package:gold_mobile/core/utils/toast_helper.dart';
import 'package:gold_mobile/core/widgets/custom_icon.dart';
import 'package:gold_mobile/core/widgets/loading_widget.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_state.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController(text: '+998 ');
  bool _isButtonEnabled = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    
    // Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
    
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(' ', '');
    setState(() {
      _isButtonEnabled = phone.length == 13 && phone.startsWith('+998');
    });
  }

  String _formatPhoneNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!digitsOnly.startsWith('+998')) {
      return '+998 ';
    }

    final withoutPrefix = digitsOnly.substring(4);
    final buffer = StringBuffer('+998 ');

    for (var i = 0; i < withoutPrefix.length && i < 9; i++) {
      if (i == 2 || i == 5 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(withoutPrefix[i]);
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSent) {
            context.push('/otp-verify', extra: state.phoneNumber);
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
                SizedBox(height: AppSizes.paddingXXL.h),
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      // Logo with shimmer
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.3),
                                ],
                                stops: [
                                  _shimmerAnimation.value - 0.3,
                                  _shimmerAnimation.value,
                                  _shimmerAnimation.value + 0.3,
                                ],
                                tileMode: TileMode.mirror,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AppAssets.logoImage,
                                width: 180,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: AppSizes.paddingLG.h),
                      // App name with shimmer
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.gold,
                                  const Color(0xFFFFE55C),
                                  AppColors.gold,
                                ],
                                stops: [
                                  _shimmerAnimation.value - 0.3,
                                  _shimmerAnimation.value,
                                  _shimmerAnimation.value + 0.3,
                                ],
                                tileMode: TileMode.mirror,
                              ).createShader(bounds);
                            },
                            child: Text(
                              AppStrings.appName,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'Playfair',
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: AppSizes.paddingSM.h),
                      Text(
                        AppStrings.appTagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.paddingXXL.h * 1.5),
                // Welcome Text
                Text(
                  AppStrings.welcomeBack,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: AppSizes.paddingSM.h),
                Text(
                  AppStrings.enterPhoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                SizedBox(height: AppSizes.paddingLG.h),
                // Phone Input
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: Theme.of(context).textTheme.titleLarge,
                  decoration: InputDecoration(
                    labelText: AppStrings.phoneNumberHint,
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: const CustomIcon(name: 'call', size: 20, color: AppColors.primary),
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(17),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final formatted = _formatPhoneNumber(newValue.text);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                ),
                const Spacer(),
                // Continue Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    
                    return ElevatedButton(
                      onPressed: _isButtonEnabled && !isLoading
                          ? () {
                              final phone = _phoneController.text.replaceAll(' ', '');
                              context.read<AuthBloc>().add(SendOtpRequested(phone));
                            }
                          : null,
                      child: isLoading
                          ? LoadingWidget(
                              size: 24,
                              color: AppColors.textOnPrimary,
                            )
                          : Text(AppStrings.continueButton),
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
