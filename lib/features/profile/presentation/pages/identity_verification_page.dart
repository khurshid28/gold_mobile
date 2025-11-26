import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'face_verification_page.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _passportController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passportController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Navigate to face verification page
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const FaceVerificationPage(),
      ),
    );

    if (!mounted) return;

    // Pass result back to profile
    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Shaxsni tasdiqlash'),
        centerTitle: true,
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
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.gold,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Shaxsni tasdiqlash uchun passport ma\'lumotlaringizni kiriting',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Passport number field
                Text(
                  'Pasport seriyasi va raqami',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passportController,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    PassportMaskFormatter(),
                  ],
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'AB 1234567',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w),
                      child: const Icon(Icons.credit_card, color: AppColors.primary),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pasport ma\'lumotlarini kiriting';
                    }
                    if (value.replaceAll(' ', '').length != 9) {
                      return 'Pasport formati noto\'g\'ri';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20.h),
                
                // Birth date field
                Text(
                  'Tug\'ilgan sana',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _birthDateController,
                  inputFormatters: [
                    DateMaskFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '01.01.1990',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w),
                      child: const Icon(Icons.calendar_today, color: AppColors.primary),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tug\'ilgan sanani kiriting';
                    }
                    if (value.length != 10) {
                      return 'Sana formati noto\'g\'ri';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 40.h),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isLoading
                        ? const LoadingWidget()
                        : Text(
                            'Tasdiqlash',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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

// Custom formatters
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PassportMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    
    // Limit to 2 letters + 7 numbers = 9 characters
    if (text.length > 9) {
      return oldValue;
    }
    
    if (text.length <= 2) {
      return TextEditingValue(
        text: text.toUpperCase(),
        selection: newValue.selection,
      );
    }
    
    final letters = text.substring(0, 2).toUpperCase();
    final numbers = text.substring(2);
    
    // Only allow numbers after letters
    if (!RegExp(r'^\d*$').hasMatch(numbers)) {
      return oldValue;
    }
    
    return TextEditingValue(
      text: '$letters $numbers',
      selection: TextSelection.collapsed(
        offset: letters.length + 1 + numbers.length,
      ),
    );
  }
}

class DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('.', '');
    
    if (text.isEmpty) {
      return newValue;
    }
    
    String formatted = '';
    for (int i = 0; i < text.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        formatted += '.';
      }
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
