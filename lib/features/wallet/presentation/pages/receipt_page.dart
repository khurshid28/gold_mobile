import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';

/// Card number masking: first 6 digits + 6 stars + last 4 digits.
/// Example: 8600 31** **** 8901
String _maskCardNumber(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) return raw;
  final padded = digits.padRight(16, '0');
  final first6 = padded.substring(0, 6);
  final last4 = padded.substring(padded.length - 4);
  final middleLen = padded.length - 10;
  final stars = '*' * middleLen;
  // group as 4-4-4-4 for readability
  final s = '$first6$stars$last4';
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && i % 4 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Beautiful "check" / receipt page for any wallet transaction.
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, required this.tx});
  final WalletTransaction tx;

  String _buildShareText() {
    final df = DateFormat('dd.MM.yyyy  HH:mm');
    final isIncome =
        tx.type == TxType.transferIn || tx.type == TxType.topUp;
    final sign = isIncome ? '+' : '-';
    final lines = <String>[
      'Gold Imperia · Chek',
      '',
      (tx.type.label),
      (tx.success ? 'Muvaffaqiyatli' : 'Bekor qilindi'),
      'Summa: $sign ${MoneyFormat.sum(tx.amount)}',
      'Sana: ${df.format(tx.date)}',
      if (tx.productName != null) 'Mahsulot: ${tx.productName}',
      if (tx.productGram != null)
        'Og\'irligi: ${tx.productGram!.toStringAsFixed(2)} gr',
      if (tx.toCardHolder != null) 'Qabul qiluvchi: ${tx.toCardHolder}',
      if (tx.toCardNumber != null)
        'Qabul qiluvchi karta: ${_maskCardNumber(tx.toCardNumber!)}',
      if (tx.merchant != null) 'Xizmat: ${tx.merchant}',
      if (tx.fee > 0) 'Komissiya: ${MoneyFormat.sum(tx.fee)}',
      if (tx.fee > 0) 'Jami: ${MoneyFormat.sum(tx.totalCharged)}',
      if (tx.note != null && tx.note!.isNotEmpty) 'Izoh: ${tx.note}',
      'ID: ${tx.id.substring(0, 8).toUpperCase()}',
    ];
    return lines.join('\n');
  }

  Future<void> _share() async {
    try {
      await Share.share(_buildShareText(), subject: 'Gold Imperia · Chek');
    } catch (_) {
      Fluttertoast.showToast(msg: 'Ulashishda xatolik');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome =
        tx.type == TxType.transferIn || tx.type == TxType.topUp;
    final color = tx.success
        ? (isIncome ? AppColors.success : AppColors.gold)
        : AppColors.error;
    final df = DateFormat('dd.MM.yyyy  HH:mm');
    final cards = context.select<WalletBloc, List<BankCard>>(
      (b) => b.state.cards,
    );
    BankCard? fromCard;
    if (tx.fromCardId != null) {
      for (final c in cards) {
        if (c.id == tx.fromCardId) {
          fromCard = c;
          break;
        }
      }
    }
    final hasProduct = tx.type == TxType.purchase &&
        (tx.productName != null || tx.productImage != null);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Chek'),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.share),
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            if (hasProduct) ...[
              _ProductHero(
                name: tx.productName ?? tx.note ?? 'Mahsulot',
                image: tx.productImage,
                gram: tx.productGram,
                merchant: tx.merchant,
                isDark: isDark,
              ),
              SizedBox(height: 14.h),
            ],
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
                  if (fromCard != null)
                    _cardRow(fromCard, isDark),
                  if (tx.toCardHolder != null)
                    _row('Qabul qiluvchi', tx.toCardHolder!),
                  if (tx.toCardNumber != null)
                    _row('Qabul qiluvchi karta',
                        _maskCardNumber(tx.toCardNumber!)),
                  if (tx.merchant != null && !hasProduct)
                    _row('Xizmat', tx.merchant!),
                  if (tx.productGram != null)
                    _row('Og\'irligi', '${tx.productGram!.toStringAsFixed(2)} gr'),
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

  Widget _cardRow(BankCard card, bool isDark) {
    final masked = _maskCardNumber(card.number);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Karta',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              masked,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({
    required this.name,
    required this.image,
    required this.gram,
    required this.merchant,
    required this.isDark,
  });
  final String name;
  final String? image;
  final double? gram;
  final String? merchant;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
        border: Border.all(
          color: AppColors.gold.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withOpacity(0.18),
                  AppColors.lightGold.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: image == null
                ? const Icon(IconsaxPlusBold.shopping_bag,
                    color: AppColors.gold, size: 32)
                : Image.asset(
                    image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      IconsaxPlusBold.shopping_bag,
                      color: AppColors.gold,
                      size: 32,
                    ),
                  ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (merchant != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    merchant!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium,
                    ),
                  ),
                ],
                if (gram != null) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(IconsaxPlusBold.weight,
                            color: AppColors.gold, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          '${gram!.toStringAsFixed(2)} gr',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
