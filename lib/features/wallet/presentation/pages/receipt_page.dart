import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';

/// Beautiful "check" / receipt page for any wallet transaction.
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, required this.tx});
  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome =
        tx.type == TxType.transferIn || tx.type == TxType.topUp;
    final color = tx.success
        ? (isIncome ? AppColors.success : AppColors.gold)
        : AppColors.error;
    final df = DateFormat('dd.MM.yyyy  HH:mm');

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Chek'),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.share),
            onPressed: () => Fluttertoast.showToast(msg: 'Chek ulashildi'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tx.success ? IconsaxPlusBold.tick_circle : IconsaxPlusBold.close_circle,
                      color: color,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    tx.success ? 'Muvaffaqiyatli' : 'Bekor qilindi',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    tx.type.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    '${isIncome ? '+' : '-'} ${MoneyFormat.sum(tx.amount)}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _Dashed(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  SizedBox(height: 14.h),
                  _row('Sana', df.format(tx.date)),
                  if (tx.toCardHolder != null)
                    _row('Qabul qiluvchi', tx.toCardHolder!),
                  if (tx.toCardNumber != null)
                    _row('Karta', tx.toCardNumber!),
                  if (tx.merchant != null) _row('Xizmat', tx.merchant!),
                  if (tx.fee > 0) _row('Komissiya', MoneyFormat.sum(tx.fee)),
                  if (tx.fee > 0)
                    _row('Jami yechildi', MoneyFormat.sum(tx.totalCharged)),
                  if (tx.note != null && tx.note!.isNotEmpty)
                    _row('Izoh', tx.note!),
                  _row('Tranzaksiya ID',
                      tx.id.substring(0, 8).toUpperCase()),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(IconsaxPlusBold.home_2),
                label: const Text('Bosh sahifa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              k,
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const dash = 6.0;
      const gap = 4.0;
      final count = (c.maxWidth / (dash + gap)).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          count,
          (_) => Container(width: dash, height: 1.5, color: color),
        ),
      );
    });
  }
}
