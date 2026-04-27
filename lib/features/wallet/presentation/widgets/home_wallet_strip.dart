import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/main_layout.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/bank_card_widget.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/total_balance_card.dart';

/// Balance card + horizontal cards slider (PageView + dots) used at the top
/// of HomePage.
class HomeWalletStrip extends StatefulWidget {
  const HomeWalletStrip({super.key});

  @override
  State<HomeWalletStrip> createState() => _HomeWalletStripState();
}

class _HomeWalletStripState extends State<HomeWalletStrip> {
  final PageController _pc = PageController(viewportFraction: 0.88);
  int _selectedIndex = 0;
  bool _hidden = false;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final cards = state.cards;
        final itemCount = cards.length + 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TotalBalanceCard(
              total: state.totalBalance,
              hidden: _hidden,
              onToggle: () => setState(() => _hidden = !_hidden),
              onTap: () => MainLayout.of(context)?.switchToTab(1),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 134.h,
              child: PageView.builder(
                controller: _pc,
                itemCount: itemCount,
                onPageChanged: (i) => setState(() => _selectedIndex = i),
                itemBuilder: (context, index) {
                  if (index == cards.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: AddCardPlaceholder(
                        compact: true,
                        onTap: () => context.push('/wallet/add-card'),
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: BankCardWidget(
                      card: cards[index],
                      compact: true,
                      showBalance: !_hidden,
                      hideNumber: _hidden,
                      onTap: () => MainLayout.of(context)?.switchToTab(1),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            _DotsIndicator(
              count: itemCount,
              index: _selectedIndex.clamp(0, itemCount - 1),
            ),
          ],
        );
      },
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
