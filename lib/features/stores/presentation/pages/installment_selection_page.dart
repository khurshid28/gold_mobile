import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../installment/presentation/pages/contract_page.dart';
import '../../../installment/presentation/widgets/pin_verification_bottom_sheet.dart';
import '../../../verification/presentation/pages/video_verification_page.dart';
import '../../domain/entities/store.dart';

class InstallmentSelectionPage extends StatefulWidget {
  final Store store;
  final VoidCallback onSuccess;

  const InstallmentSelectionPage({
    super.key,
    required this.store,
    required this.onSuccess,
  });

  @override
  State<InstallmentSelectionPage> createState() =>
      _InstallmentSelectionPageState();
}

class _InstallmentSelectionPageState extends State<InstallmentSelectionPage> {
  // Sample product data
  final String productName = 'Tilla uzuk';
  final double productPrice = 5000000.0;
  int selectedMonths = 6;

  // Interest rates
  double _getInterestRate(int months) {
    switch (months) {
      case 3:
        return 0.10; // 10%
      case 6:
        return 0.15; // 15%
      case 9:
        return 0.20; // 20%
      case 12:
        return 0.30; // 30%
      default:
        return 0.15;
    }
  }

  double _getTotalAmount(int months) {
    final rate = _getInterestRate(months);
    return productPrice * (1 + rate);
  }

  double _getMonthlyPayment(int months) {
    return _getTotalAmount(months) / months;
  }

  void _proceedToContract() {
    final totalAmount = _getTotalAmount(selectedMonths);
    final monthlyPayment = _getMonthlyPayment(selectedMonths);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(
          productId: 'store_${widget.store.id}',
          productName: productName,
          productImage: widget.store.imageUrl,
          productPrice: totalAmount,
          selectedMonths: selectedMonths,
          monthlyPayment: monthlyPayment,
          onAgree: () {
            _showPinVerificationBottomSheet();
          },
        ),
      ),
    );
  }

  void _showPinVerificationBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => PinVerificationBottomSheet(
        isDark: isDark,
        onVerified: () async {
          Navigator.pop(context); // Close bottom sheet

          // Navigate to video verification
          final videoCompleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const VideoVerificationPage(),
            ),
          );

          // Show success only if video was completed
          if (mounted && videoCompleted == true) {
            _showSuccessDialog();
          }
        },
      ),
    );
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAmount = _getTotalAmount(selectedMonths);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIcon(
                name: 'check_circle',
                color: AppColors.success,
                size: 50,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Muvaffaqiyatli!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Bo\'lib to\'lash shartnomasi tuzildi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textMediumOnDark
                    : AppColors.textMedium,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.store.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Limitingizdan ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(totalAmount)} so\'m ayrildi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textMediumOnDark
                      : AppColors.textMedium,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close installment page
                widget.onSuccess();
              },
              child: const Text('Mening haridlarimga o\'tish'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bo\'lib to\'lash'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store and Product Info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIcon(
                        name: 'store',
                        color: AppColors.gold,
                        size: 24,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.store.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textDarkOnDark
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Mahsulot: $productName',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Narxi: ${formatter.format(productPrice)} so\'m',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Select Installment Period
            Text(
              'Muddatni tanlang',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),

            // Installment Options
            ...([3, 6, 9, 12].map((months) {
              final isSelected = selectedMonths == months;
              final rate = _getInterestRate(months);
              final monthlyPayment = _getMonthlyPayment(months);
              final totalAmount = _getTotalAmount(months);

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedMonths = months;
                    });
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withOpacity(0.15)
                          : (isDark
                                ? AppColors.cardBackgroundDark
                                : AppColors.cardBackgroundLight),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.gold.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio
                        Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.gold
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 8.w,
                                    height: 8.h,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '$months oy',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.gold
                                          : (isDark
                                                ? AppColors.textDarkOnDark
                                                : AppColors.textDark),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '+${(rate * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Oylik to\'lov:',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isDark
                                      ? AppColors.textMediumOnDark
                                      : AppColors.textMedium,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${formatter.format(monthlyPayment)} so\'m',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textDarkOnDark
                                      : AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Jami: ${formatter.format(totalAmount)} so\'m',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isDark
                                      ? AppColors.textMediumOnDark
                                      : AppColors.textMedium,
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
            }).toList()),

            SizedBox(height: 24.h),

            // Info Box
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomIcon(name: 'info', color: AppColors.info, size: 20),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Shartnoma tuzilgandan so\'ng to\'liq summa limitingizdan ayriladi. Oylik to\'lovlar bo\'yicha to\'lab borganda limit tiklanadi.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textMediumOnDark
                            : AppColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackgroundDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _proceedToContract,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(
              'Davom etish',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
