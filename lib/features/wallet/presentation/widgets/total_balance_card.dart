import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/utils/money_format.dart';

/// Shared "Umumiy balans" gold gradient card used on Home and Wallet pages.
/// Identical layout/sizing in both places.
class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({
    super.key,
    required this.total,
    required this.hidden,
    required this.onToggle,
    this.onTap,
  });

  final double total;
  final bool hidden;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F1B16), Color(0xFF6B5320), Color(0xFFD4AF37)],
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(IconsaxPlusBold.wallet_2,
                    color: Colors.white, size: 26),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Umumiy balans',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12.sp,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hidden ? '•••••• so\'m' : MoneyFormat.sum(total),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggle,
                tooltip: hidden ? 'Ko\'rsatish' : 'Yashirish',
                icon: Icon(
                  hidden ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye,
                  color: isDark ? Colors.white70 : Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
