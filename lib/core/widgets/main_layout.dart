import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:gold_mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:gold_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:gold_mobile/features/home/presentation/pages/home_page.dart';
import 'package:gold_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/wallet_page.dart';

/// Bottom-nav tab descriptor.
class _Tab {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final Widget page;
  const _Tab({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.page,
  });
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();

  static _MainLayoutState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainLayoutState>();
  }
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex = widget.initialIndex.clamp(0, 3);

  void switchToTab(int index) => setState(() => _currentIndex = index);

  static const _tabs = <_Tab>[
    _Tab(
      icon: IconsaxPlusLinear.home_2,
      iconActive: IconsaxPlusBold.home_2,
      label: 'Bosh',
      page: HomePage(),
    ),
    _Tab(
      icon: IconsaxPlusLinear.wallet_2,
      iconActive: IconsaxPlusBold.wallet_2,
      label: 'Hamyon',
      page: WalletPage(),
    ),
    _Tab(
      icon: IconsaxPlusLinear.shopping_bag,
      iconActive: IconsaxPlusBold.shopping_bag,
      label: 'Savat',
      page: CartPage(),
    ),
    _Tab(
      icon: IconsaxPlusLinear.profile_circle,
      iconActive: IconsaxPlusBold.profile_circle,
      label: 'Profil',
      page: ProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((t) => t.page).toList(),
      ),
      bottomNavigationBar: _GoldBottomBar(
        items: _tabs,
        index: _currentIndex,
        onTap: switchToTab,
        isDark: isDark,
      ),
    );
  }
}

class _GoldBottomBar extends StatelessWidget {
  const _GoldBottomBar({
    required this.items,
    required this.index,
    required this.onTap,
    required this.isDark,
  });

  final List<_Tab> items;
  final int index;
  final ValueChanged<int> onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: AppColors.gold.withOpacity(isDark ? 0.35 : 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final t = items[i];
            final selected = i == index;
            return _NavItem(
              tab: t,
              selected: selected,
              isDark: isDark,
              onTap: () => onTap(i),
              badge: _badgeFor(i),
            );
          }),
        ),
      ),
    );
  }

  Widget? _badgeFor(int i) {
    if (i == 2) {
      return BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final n = state is CartLoaded ? state.items.length : 0;
          return _CountBadge(count: n);
        },
      );
    }
    return null;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
    required this.isDark,
    this.badge,
  });

  final _Tab tab;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 14.w : 12.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFE8C669), Color(0xFFD4AF37)],
                )
              : null,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? tab.iconActive : tab.icon,
                  size: 22,
                  color: selected
                      ? Colors.black
                      : (isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium),
                ),
                if (badge != null)
                  Positioned(right: -8, top: -6, child: badge!),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
