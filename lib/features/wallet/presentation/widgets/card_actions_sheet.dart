import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/bank_card_widget.dart';

/// Bottom sheet shown when tapping a bank card on the wallet/home pages.
/// Provides:
///  - Tarix (history filtered by this card)
///  - Asosiy karta qilish (set primary)
///  - O'chirish (remove)
Future<void> showCardActionsSheet(
  BuildContext context, {
  required BankCard card,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    builder: (ctx) => _CardActionsSheet(card: card, isDark: isDark),
  );
}

class _CardActionsSheet extends StatelessWidget {
  const _CardActionsSheet({required this.card, required this.isDark});
  final BankCard card;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            // Live preview of the card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: BankCardWidget(
                card: card,
                compact: true,
                height: 140.h,
              ),
            ),
            SizedBox(height: 14.h),
            if (card.isPrimary)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(IconsaxPlusBold.star_1,
                        color: AppColors.gold, size: 16),
                    SizedBox(width: 8.w),
                    Text(
                      'Asosiy karta',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            _ActionTile(
              icon: IconsaxPlusBold.clock,
              color: AppColors.gold,
              title: 'Tarix',
              subtitle: 'Ushbu karta amaliyotlari',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/wallet/history', extra: card.id);
              },
            ),
            SizedBox(height: 8.h),
            _ActionTile(
              icon: IconsaxPlusBold.star_1,
              color: AppColors.gold,
              title: card.isPrimary
                  ? 'Asosiy karta'
                  : 'Asosiy karta qilish',
              subtitle: card.isPrimary
                  ? 'Ushbu karta hozir asosiy'
                  : 'Tezkor amallarda shu karta tanlanadi',
              isDark: isDark,
              enabled: !card.isPrimary,
              onTap: () {
                context.read<WalletBloc>().add(SetPrimaryCard(card.id));
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'Asosiy karta o\'zgartirildi',
                  backgroundColor: AppColors.gold,
                  textColor: Colors.black,
                );
              },
            ),
            SizedBox(height: 8.h),
            _ActionTile(
              icon: IconsaxPlusBold.trash,
              color: AppColors.error,
              title: 'O\'chirish',
              subtitle: 'Kartani hisobdan olib tashlash',
              isDark: isDark,
              onTap: () => _confirmDelete(context),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext sheetCtx) async {
    final ok = await showDialog<bool>(
      context: sheetCtx,
      builder: (ctx) => AlertDialog(
        title: const Text('Kartani o\'chirish'),
        content: Text(
          'Kartani ro\'yxatdan olib tashlaysizmi? Bu amalni qaytarib bo\'lmaydi.',
          style: TextStyle(fontSize: 14.sp),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (ok == true && sheetCtx.mounted) {
      sheetCtx.read<WalletBloc>().add(RemoveCard(card.id));
      Navigator.of(sheetCtx).pop();
      Fluttertoast.showToast(
        msg: 'Karta o\'chirildi',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.enabled = true,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
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
                Icon(
                  IconsaxPlusLinear.arrow_right_3,
                  color: isDark
                      ? AppColors.textMediumOnDark
                      : AppColors.textMedium,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
