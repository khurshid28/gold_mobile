import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../domain/entities/purchase.dart';

class InstallmentDetailsPage extends StatelessWidget {
  final Purchase purchase;

  const InstallmentDetailsPage({
    super.key,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final details = purchase.installmentDetails!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
        title: const Text('To\'lov jadvali'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product header
            Container(
              padding: EdgeInsets.all(20.w),
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
                    borderRadius: BorderRadius.circular(12.r),
                    child: CachedNetworkImage(
                      imageUrl: purchase.productImage,
                      width: 90.w,
                      height: 90.h,
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
                        child: Icon(
                          Icons.image_rounded,
                          color: AppColors.gold,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textDarkOnDark
                                : AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          NumberFormat.currency(symbol: '', decimalDigits: 0)
                                  .format(purchase.totalPrice) +
                              ' so\'m',
                          style: TextStyle(
                            fontSize: 18.sp,
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

            // Progress summary
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull.r),
                          child: LinearProgressIndicator(
                            value: details.progressPercentage / 100,
                            minHeight: 10.h,
                            backgroundColor: isDark
                                ? AppColors.cardBackgroundDark
                                : AppColors.cardBackgroundLight,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(AppColors.gold),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${details.paidMonths}/${details.totalMonths}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'To\'langan',
                          value: NumberFormat.currency(
                                      symbol: '', decimalDigits: 0)
                                  .format(details.totalAmount -
                                      details.remainingAmount),
                          unit: 'so\'m',
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatCard(
                          label: 'Qolgan',
                          value: NumberFormat.currency(
                                      symbol: '', decimalDigits: 0)
                                  .format(details.remainingAmount),
                          unit: 'so\'m',
                          color: AppColors.error,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Oylik',
                          value: NumberFormat.currency(
                                      symbol: '', decimalDigits: 0)
                                  .format(details.monthlyPayment),
                          unit: 'so\'m',
                          color: AppColors.gold,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatCard(
                          label: 'Keyingi to\'lov',
                          value: DateFormat('dd.MM.yyyy')
                              .format(details.nextPaymentDate),
                          unit: '',
                          color: AppColors.info,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Monthly payments list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oylik to\'lovlar',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _MonthlyPaymentsList(
                    details: details,
                    isDark: isDark,
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? AppColors.textLightOnDark : AppColors.textLight,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 4.w),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? AppColors.textLightOnDark : AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyPaymentsList extends StatelessWidget {
  final InstallmentDetails details;
  final bool isDark;

  const _MonthlyPaymentsList({
    required this.details,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      children: List.generate(details.totalMonths, (index) {
        final monthNumber = index + 1;
        final isPaid = monthNumber <= details.paidMonths;
        
        // Calculate payment date: 15th of each month starting from purchase date
        final purchaseDate = DateTime.now(); // Should come from purchase.purchaseDate
        final paymentDate = DateTime(
          purchaseDate.year,
          purchaseDate.month + monthNumber,
          15, // Always 15th of the month
        );
        
        final isOverdue = !isPaid && paymentDate.isBefore(now);

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.success.withOpacity(0.08)
                  : isOverdue
                      ? AppColors.error.withOpacity(0.08)
                      : isDark
                          ? AppColors.cardBackgroundDark
                          : AppColors.cardBackgroundLight,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isPaid
                    ? AppColors.success.withOpacity(0.3)
                    : isOverdue
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.gold.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppColors.success
                        : isOverdue
                            ? AppColors.error
                            : AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isPaid
                        ? const CustomIcon(
                            name: 'check_circle',
                            size: 20,
                            color: Colors.white,
                          )
                        : isOverdue
                            ? const CustomIcon(
                                name: 'close',
                                size: 20,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.schedule_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Month info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$monthNumber-oy',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textDarkOnDark
                              : AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        DateFormat('dd.MM.yyyy').format(paymentDate),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.textLightOnDark
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(symbol: '', decimalDigits: 0)
                          .format(details.monthlyPayment),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: isPaid
                            ? AppColors.success
                            : isOverdue
                                ? AppColors.error
                                : AppColors.gold,
                      ),
                    ),
                    Text(
                      'so\'m',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? AppColors.textLightOnDark
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
