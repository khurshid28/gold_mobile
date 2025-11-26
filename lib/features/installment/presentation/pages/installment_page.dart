import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import 'contract_page.dart';

class InstallmentPage extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;

  const InstallmentPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
  });

  @override
  State<InstallmentPage> createState() => _InstallmentPageState();
}

class _InstallmentPageState extends State<InstallmentPage> {
  int _selectedMonths = 12;
  final List<int> _monthOptions = [3, 6, 9, 12];

  double get _monthlyPayment => widget.productPrice / _selectedMonths;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
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
        title: const Text('Bo\'lib to\'lash'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Container(
              padding: EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
                    child: CachedNetworkImage(
                      imageUrl: widget.productImage,
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : AppColors.cardBackgroundLight,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : AppColors.cardBackgroundLight,
                        child: Icon(Icons.image_rounded, color: AppColors.gold),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.paddingMD.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
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
                          NumberFormat.currency(
                                symbol: '',
                                decimalDigits: 0,
                              ).format(widget.productPrice) +
                              ' so\'m',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMD.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizes.paddingMD.h),

                  // Title
                  Text(
                    'Muddat tanlang',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingMD.h),

                  // Month options
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: _monthOptions.map((months) {
                      final isSelected = _selectedMonths == months;
                      return _MonthChip(
                        months: months,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedMonths = months;
                          });
                        },
                        isDark: isDark,
                      );
                    }).toList(),
                  ),

                  SizedBox(height: AppSizes.paddingXL.h),

                  // Payment details card
                  Container(
                    padding: EdgeInsets.all(AppSizes.paddingMD.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withOpacity(0.1),
                          AppColors.primaryLight.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Monthly payment
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Oylik to\'lov:',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: isDark
                                    ? AppColors.textMediumOnDark
                                    : AppColors.textMedium,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                    symbol: '',
                                    decimalDigits: 0,
                                  ).format(_monthlyPayment) +
                                  ' so\'m',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.paddingMD.h),
                        Divider(color: AppColors.gold.withOpacity(0.3)),
                        SizedBox(height: AppSizes.paddingMD.h),

                        // Details rows
                        _DetailRow(
                          label: 'Muddat',
                          value: '$_selectedMonths oy',
                          isDark: isDark,
                        ),
                        SizedBox(height: AppSizes.paddingSM.h),
                        _DetailRow(
                          label: 'Jami summa',
                          value:
                              NumberFormat.currency(
                                symbol: '',
                                decimalDigits: 0,
                              ).format(widget.productPrice) +
                              ' so\'m',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizes.paddingXL.h),

                  // Benefits
                  Text(
                    'Afzalliklar',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingMD.h),

                  _BenefitItem(
                    iconName: 'check_circle',
                    text: 'Boshlang\'ich to\'lovsiz',
                    isDark: isDark,
                  ),
                  _BenefitItem(
                    iconName: 'check_circle',
                    text: 'Foizsiz to\'lov',
                    isDark: isDark,
                  ),
                  _BenefitItem(
                    iconName: 'check_circle',
                    text: 'Tezkor rasmiylashtirish',
                    isDark: isDark,
                  ),
                  _BenefitItem(
                    iconName: 'check_circle',
                    text: 'Erkin muddatni tanlash',
                    isDark: isDark,
                  ),

                  SizedBox(height: AppSizes.paddingXL.h),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to verification
                        _showConfirmationDialog(context, isDark);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMD.h,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIcon(
                            name: 'check_circle',
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Bo\'lib to\'lash',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizes.paddingXL.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 12.w),
            Text('Tasdiqlash'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mahsulot: ${widget.productName}'),
            SizedBox(height: AppSizes.paddingSM.h),
            Text(
              'Narx: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(widget.productPrice)} so\'m',
            ),
            SizedBox(height: AppSizes.paddingSM.h),
            Text('Muddat: $_selectedMonths oy'),
            SizedBox(height: AppSizes.paddingSM.h),
            Text(
              'Oylik to\'lov: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_monthlyPayment)} so\'m',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
            SizedBox(height: AppSizes.paddingMD.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: AppColors.info, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Tasdiqlash uchun SMS kod yuboriladi',
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContractBottomSheet(context, isDark);
            },
            child: const Text('Davom etish'),
          ),
        ],
      ),
    );
  }

  void _showContractBottomSheet(BuildContext context, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(
          productId: widget.productId,
          productName: widget.productName,
          productImage: widget.productImage,
          productPrice: widget.productPrice,
          selectedMonths: _selectedMonths,
          monthlyPayment: _monthlyPayment,
          onAgree: () {
            _showPinVerificationBottomSheet(context, isDark);
          },
        ),
      ),
    );
  }

  void _showPinVerificationBottomSheet(BuildContext context, bool isDark) {
    // This method is now called from ContractPage after video verification
    _showSuccessDialog(context, isDark);
  }

  void _showSuccessDialog(BuildContext context, bool isDark) {
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
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 50.sp,
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
              '${widget.productName}',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
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
                context.push('/my-purchases');
              },
              child: const Text('Mening haridlarimga o\'tish'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  final int months;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _MonthChip({
    required this.months,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold
              : (isDark
                    ? AppColors.cardBackgroundDark
                    : AppColors.cardBackgroundLight),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              '$months',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textDarkOnDark : AppColors.textDark),
              ),
            ),
            Text(
              'oy',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : (isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontMD.sp,
            color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.fontMD.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String iconName;
  final String text;
  final bool isDark;

  const _BenefitItem({
    required this.iconName,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.paddingSM.h),
      child: Row(
        children: [
          CustomIcon(name: iconName, size: 22, color: AppColors.success),
          SizedBox(width: AppSizes.paddingSM.w),
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontMD.sp,
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
