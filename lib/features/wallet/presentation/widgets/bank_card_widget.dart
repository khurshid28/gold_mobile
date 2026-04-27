import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';

/// Reusable beautiful bank card with gradient by [BankCard.colorSeed]
/// and brand chip (UZCARD / HUMO / VISA).
class BankCardWidget extends StatelessWidget {
  const BankCardWidget({
    super.key,
    required this.card,
    this.compact = false,
    this.showBalance = true,
    this.hideNumber = false,
    this.hideBrand = false,
    this.onTap,
    this.width,
    this.height,
  });

  final BankCard card;
  final bool compact;
  final bool showBalance;
  final bool hideNumber;
  final bool hideBrand;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  // All cards use the same elegant black palette.
  static const List<Color> _palette = [
    Color(0xFF000000),
    Color(0xFF111111),
    Color(0xFF1A1A1A),
  ];

  @override
  Widget build(BuildContext context) {
    final w = width ?? double.infinity;
    final h = height ?? (compact ? 134.h : 200.h);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _palette,
          ),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.25),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Decorative circles — span full card edges (no inner padding)
              Positioned(
                right: -30,
                top: -30,
                child: _circle(120, Colors.white.withOpacity(0.06)),
              ),
              Positioned(
                right: 30,
                bottom: -40,
                child: _circle(100, Colors.white.withOpacity(0.04)),
              ),
              Padding(
                padding: EdgeInsets.all(compact ? 14.w : 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(IconsaxPlusBold.card,
                            color: Colors.white.withOpacity(0.85),
                            size: compact ? 20 : 26),
                        SizedBox(width: 8.w),
                        Text(
                      'Gold Imperia',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: compact ? 11.sp : 13.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    if (!hideBrand) _BrandChip(type: card.type, compact: compact),
                  ],
                ),
                const Spacer(),
                if (showBalance && !compact) ...[
                  Text(
                    'Balans',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11.sp,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    MoneyFormat.sum(card.balance),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                Text(
                  hideNumber
                      ? card.masked
                      : (compact ? card.masked : card.formatted),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 13.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(height: compact ? 4.h : 10.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.holder,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: compact ? 10.sp : 12.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      card.expiry,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: compact ? 10.sp : 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (compact && showBalance) ...[
                  SizedBox(height: 4.h),
                  Text(
                    MoneyFormat.sum(card.balance),
                    style: TextStyle(
                      color: AppColors.lightGold,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.type, required this.compact});
  final CardType type;
  final bool compact;

  static const _uzcardAsset = 'assets/images/uzcard.png';
  static const _humoAsset = 'assets/images/humo.png';

  @override
  Widget build(BuildContext context) {
    final h = compact ? 26.0 : 34.0;
    final w = compact ? 64.0 : 90.0;
    // HUMO source PNG has a lot of inner whitespace/padding so it looks
    // smaller than UZCARD at the same box size. Scale it visually without
    // changing the layout box.
    final isHumo = type == CardType.humo;
    final scale = isHumo ? 1.5 : 1.0;

    if (type == CardType.visa) {
      return Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 14.sp : 18.sp,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.5,
        ),
      );
    }

    final asset = type == CardType.uzcard ? _uzcardAsset : _humoAsset;
    return SizedBox(
      width: w,
      height: h,
      child: ClipRect(
        child: OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: w * scale,
          maxHeight: h * scale,
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              1, 0, 0, 0, 0,
              0, 1, 0, 0, 0,
              0, 0, 1, 0, 0,
              0.299, 0.587, 0.114, 0, 0,
            ]),
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Text(
                type == CardType.uzcard ? 'UZCARD' : 'HUMO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 11.sp : 13.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder shown in horizontal lists when no card exists.
class AddCardPlaceholder extends StatelessWidget {
  const AddCardPlaceholder({super.key, required this.onTap, this.compact = false});
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: compact ? 134.h : 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          color: (isDark ? AppColors.cardBackgroundDark : Colors.white)
              .withOpacity(0.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconsaxPlusBold.card_add,
                color: AppColors.gold, size: compact ? 28 : 36),
            SizedBox(height: 6.h),
            Text(
              'Karta qo\'shish',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12.sp : 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
