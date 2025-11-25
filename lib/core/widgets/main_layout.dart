import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_strings.dart';
import 'package:gold_mobile/features/home/presentation/pages/home_page.dart';
import 'package:gold_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:gold_mobile/features/favorites/presentation/pages/favorites_page.dart';
import 'package:gold_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:gold_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:gold_mobile/features/cart/presentation/bloc/cart_state.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
  
  static _MainLayoutState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainLayoutState>();
  }
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const FavoritesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Center(
              child: SvgPicture.asset(
                'assets/images/home_icon.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            ),
            activeIcon: Center(
              child: SvgPicture.asset(
                'assets/images/home_icon_filled.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            ),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: SvgPicture.asset(
                'assets/images/heart_icon.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            ),
            activeIcon: Center(
              child: SvgPicture.asset(
                'assets/images/heart_icon_filled.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            ),
            label: AppStrings.favorites,
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: _buildCartIcon(context, false),
            ),
            activeIcon: Center(
              child: _buildCartIcon(context, true),
            ),
            label: 'Savat',
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: SvgPicture.asset(
                'assets/images/profile_icon.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            ),
            activeIcon: Center(
              child: SvgPicture.asset(
                'assets/images/profile_icon_filled.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            ),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context, bool isActive) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final itemCount = state is CartLoaded ? state.items.length : 0;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            SvgPicture.asset(
              isActive ? 'assets/images/cart_icon_filled.svg' : 'assets/images/cart_icon.svg',
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.primary : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
            if (itemCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      itemCount > 99 ? '99+' : itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
