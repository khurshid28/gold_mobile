import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/bank_card_widget.dart';

/// Compact selected-card preview tile. Tapping it opens a beautiful
/// bottom-sheet picker showing all cards plus an "Add card" entry.
class CardPickerTile extends StatelessWidget {
  const CardPickerTile({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final BankCard selected;
  final ValueChanged<BankCard> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final cards = context.read<WalletBloc>().state.cards;
    final picked = await showModalBottomSheet<BankCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (sheetCtx) => _CardPickerSheet(
        cards: cards,
        selectedId: selected.id,
      ),
    );
    if (picked != null && picked.id != selected.id) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-read freshest balance from bloc.
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final fresh = state.cards.firstWhere(
          (c) => c.id == selected.id,
          orElse: () => selected,
        );
        return GestureDetector(
          onTap: () => _openPicker(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardBackgroundDark
                  : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _MiniCard(card: fresh),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '•••• ${_last4(fresh.number)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        MoneyFormat.sum(fresh.balance),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(IconsaxPlusLinear.arrow_down_1,
                    color: AppColors.gold, size: 22.sp),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _last4(String number) {
    final digits = number.replaceAll(RegExp(r'\s+'), '');
    if (digits.length < 4) return digits;
    return digits.substring(digits.length - 4);
  }
}

/// Small chip-style card preview (logo strip + last4) used inside the tile.
class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.card});
  final BankCard card;

  static const _uzcardAsset = 'assets/images/uzcard.png';
  static const _humoAsset = 'assets/images/humo.png';

  Widget _logo() {
    if (card.type == CardType.visa) {
      return Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.2,
        ),
      );
    }
    final asset =
        card.type == CardType.uzcard ? _uzcardAsset : _humoAsset;
    final isHumo = card.type == CardType.humo;
    final w = 44.0;
    final h = 22.0;
    final scale = isHumo ? 1.5 : 1.0;
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
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 42.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.5),
          width: 0.8,
        ),
      ),
      alignment: Alignment.center,
      child: _logo(),
    );
  }
}

class _CardPickerSheet extends StatelessWidget {
  const _CardPickerSheet({required this.cards, required this.selectedId});
  final List<BankCard> cards;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Karta tanlash',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 14.h),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cards.length + 1,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  if (i == cards.length) {
                    return _AddCardTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/wallet/add-card');
                      },
                    );
                  }
                  final c = cards[i];
                  final isSelected = c.id == selectedId;
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: BankCardWidget(card: c, compact: true),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCardTile extends StatelessWidget {
  const _AddCardTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 134.h,
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.6),
            width: 1.4,
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(IconsaxPlusBold.add,
                  color: Colors.black, size: 22),
            ),
            SizedBox(height: 8.h),
            Text(
              'Yangi karta qo\'shish',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
