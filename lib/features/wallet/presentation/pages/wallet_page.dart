import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/bank_card_widget.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/card_actions_sheet.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/total_balance_card.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _hidden = false;
  final PageController _pc = PageController(viewportFraction: 0.88);
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Hamyon'),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state.loading && state.cards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = state.cards;
          final selected = cards.isNotEmpty
              ? cards.firstWhere(
                  (c) => c.isPrimary,
                  orElse: () => cards.first,
                )
              : null;

          return RefreshIndicator(
            onRefresh: () async => context.read<WalletBloc>().add(const LoadWallet()),
            child: ListView(
              padding: EdgeInsets.only(bottom: 110.h),
              children: [
                SizedBox(height: 8.h),
                TotalBalanceCard(
                  total: state.totalBalance,
                  hidden: _hidden,
                  onToggle: () => setState(() => _hidden = !_hidden),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  height: 168.h,
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: cards.length + 1,
                    clipBehavior: Clip.none,
                    onPageChanged: (i) =>
                        setState(() => _selectedIndex = i),
                    itemBuilder: (context, index) {
                      if (index == cards.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 14.h),
                          child: AddCardPlaceholder(
                            compact: true,
                            onTap: () => context.push('/wallet/add-card'),
                          ),
                        );
                      }
                      final card = cards[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 14.h),
                        child: BankCardWidget(
                          card: card,
                          compact: true,
                          height: 134.h,
                          showBalance: !_hidden,
                          hideNumber: _hidden,
                          onTap: () =>
                              showCardActionsSheet(context, card: card),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                _DotsIndicator(
                  count: cards.length + 1,
                  index:
                      _selectedIndex.clamp(0, cards.length).toInt(),
                ),
                SizedBox(height: 18.h),
                _QuickActions(selected: selected),
                SizedBox(height: 20.h),
                _SectionTitle(
                  title: 'Oxirgi amaliyotlar',
                  trailing: TextButton(
                    onPressed: () => context.push('/wallet/history'),
                    child: const Text('Barchasi'),
                  ),
                ),
                if (state.transactions.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Center(
                      child: Text(
                        'Hozircha amaliyotlar yo\'q',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMediumOnDark
                              : AppColors.textMedium,
                        ),
                      ),
                    ),
                  )
                else
                  ...state.transactions
                      .take(5)
                      .map((tx) => _TxTile(
                            tx: tx,
                            cards: state.cards,
                            onTap: () => context.push('/wallet/receipt', extra: tx),
                          )),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----- Pieces -----

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.selected});
  final BankCard? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _ActionItem(
            icon: IconsaxPlusBold.arrow_swap_horizontal,
            label: 'O\'tkazma',
            color: const Color(0xFF2E7D32),
            onTap: selected == null
                ? null
                : () => context.push('/wallet/transfer', extra: selected),
          ),
          _ActionItem(
            icon: IconsaxPlusBold.wallet_money,
            label: 'To\'lovlar',
            color: const Color(0xFFEF6C00),
            onTap: selected == null
                ? null
                : () => context.push('/wallet/payments', extra: selected),
          ),
          _ActionItem(
            icon: IconsaxPlusBold.card_add,
            label: 'Karta',
            color: const Color(0xFF6A1B9A),
            onTap: () => context.push('/wallet/add-card'),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabled = onTap == null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Column(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textDarkOnDark
                      : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 8.w, 4.h),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx, required this.cards, this.onTap});
  final WalletTransaction tx;
  final List<BankCard> cards;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = tx.type == TxType.transferIn || tx.type == TxType.topUp;
    final color = isIncome ? AppColors.success : AppColors.error;
    final sign = isIncome ? '+' : '-';

    IconData icon;
    switch (tx.type) {
      case TxType.transferOut:
        icon = IconsaxPlusBold.arrow_up_3;
        break;
      case TxType.transferIn:
        icon = IconsaxPlusBold.arrow_down;
        break;
      case TxType.topUp:
        icon = IconsaxPlusBold.add_circle;
        break;
      case TxType.payment:
        icon = IconsaxPlusBold.receipt_2_1;
        break;
      case TxType.purchase:
        icon = IconsaxPlusBold.shopping_bag;
        break;
    }

    String subtitle;
    switch (tx.type) {
      case TxType.transferOut:
        subtitle = tx.toCardHolder ?? tx.toCardNumber ?? 'O\'tkazma';
        break;
      case TxType.payment:
      case TxType.purchase:
        subtitle = tx.merchant ?? tx.note ?? '—';
        break;
      default:
        subtitle = tx.note ?? tx.type.label;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
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
                    tx.type.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '$sign ${MoneyFormat.sum(tx.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});
  final int count;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: active ? 16.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: active ? AppColors.gold : AppColors.gold.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
      }),
    );
  }
}
