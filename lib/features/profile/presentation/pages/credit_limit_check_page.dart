import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/services/notification_service.dart';
import '../../../installment/presentation/widgets/pin_verification_bottom_sheet.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class CreditLimitCheckPage extends StatefulWidget {
  const CreditLimitCheckPage({super.key});

  @override
  State<CreditLimitCheckPage> createState() => _CreditLimitCheckPageState();
}

class _CreditLimitCheckPageState extends State<CreditLimitCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  bool _isChecking = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _formatCardNumber(String value) {
    // Remove all spaces
    final digitsOnly = value.replaceAll(' ', '');

    // Add space every 4 digits
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    _cardNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _formatExpiry(String value) {
    // Remove all slashes
    final digitsOnly = value.replaceAll('/', '');

    // Add slash after 2 digits
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 4; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }

    _expiryController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _checkLimit() {
    if (!_formKey.currentState!.validate()) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show OTP bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PinVerificationBottomSheet(
        isDark: isDark,
        title: 'Kartani tasdiqlash',
        onVerified: () {
          Navigator.pop(context);
          _performLimitCheck();
        },
      ),
    );
  }

  Future<void> _performLimitCheck() async {
    setState(() => _isChecking = true);

    // Show checking dialog with timer
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Auto-close after 30 seconds and show notification
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted) {
            Navigator.pop(context); // Close checking dialog
            _showLimitNotification();
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingWidget(
                size: 60,
                color: AppColors.gold,
                strokeWidth: 4,
              ),
              SizedBox(height: 24.h),
              Text(
                'Limit tekshirilmoqda...',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Bu 30 soniya vaqt olishi mumkin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? AppColors.textMediumOnDark
                      : AppColors.textMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLimitNotification() async {
    setState(() => _isChecking = false);

    // Get user info from auth bloc
    final authState = context.read<AuthBloc>().state;
    String fullName = 'Foydalanuvchi';

    if (authState is AuthAuthenticated) {
      fullName = authState.user.name ?? 'Foydalanuvchi';
    }

    final limit = 20000000.0; // 20 million
    final expiryDate = DateTime.now().add(const Duration(days: 365)); // 1 year

    // Update user's credit limit in auth bloc
    if (authState is AuthAuthenticated) {
      context.read<AuthBloc>().add(
        UpdateUserProfile(
          name: authState.user.name,
          isVerified: authState.user.isVerified,
          creditLimit: limit,
          limitExpiryDate: expiryDate,
        ),
      );
    }

    // Show local notification (works even when app is closed/background)
    await NotificationService().showSuccessNotification(
      title: 'Limit ajratildi! 🎉',
      body: '$fullName, sizga 20,000,000 so\'m limit ajratildi',
    );

    // Wait a bit for notification to show
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate back with result
    if (mounted) {
      Navigator.pop(context, {'limit': limit, 'expiryDate': expiryDate});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limitni tekshirish'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CustomIcon(
                        name: 'credit_card',
                        color: AppColors.gold,
                        size: 24,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Karta ma\'lumotlarini kiriting va limitni tekshiring',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? AppColors.textMediumOnDark
                                : AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Card number input
                Text(
                  'Karta raqami',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textDarkOnDark
                        : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0000 0000 0000 0000',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: CustomIcon(
                        name: 'credit_card',
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 48.w,
                      minHeight: 20.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLength: 19, // 16 digits + 3 spaces
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  onChanged: _formatCardNumber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Karta raqamini kiriting';
                    }
                    final digitsOnly = value.replaceAll(' ', '');
                    if (digitsOnly.length != 16) {
                      return 'To\'liq karta raqamini kiriting';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Expiry date input
                Text(
                  'Amal qilish muddati',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textDarkOnDark
                        : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'OO/YY',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: CustomIcon(
                        name: 'calendar',
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 48.w,
                      minHeight: 20.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLength: 5, // MM/YY
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  onChanged: _formatExpiry,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amal qilish muddatini kiriting';
                    }
                    if (value.length != 5) {
                      return 'To\'g\'ri formatda kiriting (OO/YY)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.h),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkLimit,
                    child: const Text('Limitni tekshirish'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
