import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../domain/entities/purchase.dart';
import '../../../verification/presentation/pages/video_verification_page.dart';
import 'installment_details_page.dart';

class MyPurchasesPage extends StatefulWidget {
  const MyPurchasesPage({super.key});

  @override
  State<MyPurchasesPage> createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  List<Purchase> purchases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasesJson = prefs.getString('purchases') ?? '[]';
      final List<dynamic> purchasesList = jsonDecode(purchasesJson);

      setState(() {
        purchases = purchasesList
            .map((json) {
              try {
                return Purchase(
                  id: json['id'] ?? '',
                  productName: json['productName'] ?? 'Noma\'lum mahsulot',
                  productImage: json['productImage'] ?? '',
                  totalPrice: (json['totalPrice'] ?? 0).toDouble(),
                  purchaseDate: json['purchaseDate'] != null
                      ? DateTime.parse(json['purchaseDate'])
                      : DateTime.now(),
                  status: json['status'] ?? 'in_progress',
                  isInstallment: json['isInstallment'] ?? false,
                  installmentDetails: json['installmentDetails'] != null
                      ? InstallmentDetails(
                          totalAmount:
                              (json['installmentDetails']['totalAmount'] ?? 0)
                                  .toDouble(),
                          monthlyPayment:
                              (json['installmentDetails']['monthlyPayment'] ??
                                      0)
                                  .toDouble(),
                          totalMonths:
                              json['installmentDetails']['totalMonths'] ?? 0,
                          paidMonths:
                              json['installmentDetails']['paidMonths'] ?? 0,
                          remainingAmount:
                              (json['installmentDetails']['remainingAmount'] ??
                                      0)
                                  .toDouble(),
                          nextPaymentDate:
                              json['installmentDetails']['nextPaymentDate'] !=
                                  null
                              ? DateTime.parse(
                                  json['installmentDetails']['nextPaymentDate'],
                                )
                              : DateTime.now(),
                        )
                      : null,
                );
              } catch (e) {
                debugPrint('Error parsing purchase: $e');
                return null;
              }
            })
            .whereType<Purchase>()
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading purchases: $e');
      setState(() {
        purchases = [];
        isLoading = false;
      });
    }
  }

  void _showContinueDialog(BuildContext context, Purchase purchase) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: AppColors.error,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Ariza yakunlanmagan',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              purchase.productName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Video tasdiqlashni yakunlashingiz kerak. Davom etishni xohlaysizmi?',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textMediumOnDark
                    : AppColors.textMedium,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Navigate to video verification
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoVerificationPage(),
                ),
              );

              // Reload purchases if video was completed
              if (result == true) {
                _loadPurchases();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
            child: const Text(
              'Davom etish',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        title: const Text('Mening haridlarim'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : purchases.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Hozircha haridlar yo\'q',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Pending purchases alert banner
                if (purchases.any((p) => p.status == 'pending'))
                  _PendingAlertBanner(
                    pendingCount: purchases
                        .where((p) => p.status == 'pending')
                        .length,
                    isDark: isDark,
                    onTap: () {
                      // Scroll to first pending purchase
                      final firstPendingIndex = purchases.indexWhere(
                        (p) => p.status == 'pending',
                      );
                      if (firstPendingIndex >= 0) {
                        // Show dialog to continue
                        _showContinueDialog(
                          context,
                          purchases[firstPendingIndex],
                        );
                      }
                    },
                  ),

                // Purchases list
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: purchases.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      return _PurchaseCard(
                        purchase: purchase,
                        isDark: isDark,
                        onTap: purchase.status == 'pending'
                            ? () => _showContinueDialog(context, purchase)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final bool isDark;
  final VoidCallback? onTap;

  const _PurchaseCard({
    required this.purchase,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16.r),
          border: purchase.status == 'pending'
              ? Border.all(color: AppColors.error.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Product info
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CachedNetworkImage(
                      imageUrl: purchase.productImage,
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
                        child: Icon(
                          Icons.image_rounded,
                          color: AppColors.gold,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textDarkOnDark
                                : AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          NumberFormat.currency(
                                symbol: '',
                                decimalDigits: 0,
                              ).format(purchase.totalPrice) +
                              ' so\'m',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat(
                            'dd.MM.yyyy',
                          ).format(purchase.purchaseDate),
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

                  // Status badge
                  _StatusBadge(status: purchase.status, isDark: isDark),
                ],
              ),
            ),

            // Installment details (if applicable)
            if (purchase.isInstallment &&
                purchase.installmentDetails != null) ...[
              Divider(
                height: 1,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              _InstallmentDetails(
                details: purchase.installmentDetails!,
                isDark: isDark,
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InstallmentDetailsPage(purchase: purchase),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PendingAlertBanner extends StatelessWidget {
  final int pendingCount;
  final bool isDark;
  final VoidCallback onTap;

  const _PendingAlertBanner({
    required this.pendingCount,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yakunlanmagan ariza!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$pendingCount ta arizani yakunlashingiz kerak',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'Yakunlanmagan';
        break;
      case 'delivered':
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'Yetkazildi';
        break;
      case 'in_progress':
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        label = 'Jarayonda';
        break;
      case 'cancelled':
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        label = 'Bekor qilindi';
        break;
      default:
        bgColor = AppColors.grey.withOpacity(0.1);
        textColor = AppColors.grey;
        label = 'Noma\'lum';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _InstallmentDetails extends StatelessWidget {
  final InstallmentDetails details;
  final bool isDark;
  final VoidCallback onViewDetails;

  const _InstallmentDetails({
    required this.details,
    required this.isDark,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull.r),
                  child: LinearProgressIndicator(
                    value: details.progressPercentage / 100,
                    minHeight: 8.h,
                    backgroundColor: isDark
                        ? AppColors.cardBackgroundDark
                        : AppColors.cardBackgroundLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '${details.paidMonths}/${details.totalMonths}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Payment info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _InfoColumn(
                  label: 'Oylik',
                  value: NumberFormat.currency(
                    symbol: '',
                    decimalDigits: 0,
                  ).format(details.monthlyPayment),
                  unit: 'so\'m',
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _InfoColumn(
                  label: 'Qolgan',
                  value: NumberFormat.currency(
                    symbol: '',
                    decimalDigits: 0,
                  ).format(details.remainingAmount),
                  unit: 'so\'m',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Next payment
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16.sp,
                  color: AppColors.gold,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Keyingi: ${DateFormat('dd.MM.yyyy').format(details.nextPaymentDate)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // View details button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.gold, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'To\'lov jadvali',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isDark;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.unit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackgroundDark
            : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(10.r),
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
                    color: isDark
                        ? AppColors.textDarkOnDark
                        : AppColors.textDark,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark
                      ? AppColors.textLightOnDark
                      : AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
