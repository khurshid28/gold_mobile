import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_sizes.dart';
import 'package:gold_mobile/core/l10n/app_localizations.dart';
import 'package:gold_mobile/core/theme/theme_cubit.dart';
import 'package:gold_mobile/core/widgets/custom_icon.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final currentTheme = themeCubit.state;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: AppSizes.paddingMD.h),
                  // Profile Header
                  _ProfileHeader(
                    name: state.user.name ?? 'Foydalanuvchi',
                    phoneNumber: state.user.phoneNumber,
                    photoUrl: state.user.photoUrl,
                  ),
                  SizedBox(height: AppSizes.paddingXL.h),
                  // Menu Items
                  _MenuSection(
                    items: [
                      _MenuItem(
                        iconName: 'shopping_bag',
                        title: AppLocalizations.of(context).myPurchases,
                        onTap: () {
                          context.push('/my-purchases');
                        },
                      ),
                      _MenuItem(
                        iconName: 'store',
                        title: AppLocalizations.of(context).stores,
                        onTap: () {
                          context.push('/stores');
                        },
                      ),
                    ],
                  ),
                   SizedBox(height: AppSizes.paddingLG.h),
                  _MenuSection(
                    items: [
                      _MenuItem(
                        iconName: 'language',
                        title: AppLocalizations.of(context).language,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'O\'zbekcha',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20.sp),
                          ],
                        ),
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                      ),
                      _MenuItem(
                        icon: currentTheme == ThemeMode.light ? Icons.light_mode_rounded : currentTheme == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.settings_suggest_rounded,
                        title: 'Mavzu',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentTheme == ThemeMode.light ? 'Yorug\'' : currentTheme == ThemeMode.dark ? 'Qorong\'i' : 'Tizim',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20.sp),
                          ],
                        ),
                        onTap: () {
                          _showThemeDialog(context, themeCubit, currentTheme);
                        },
                      ),
                      _MenuItem(
                        iconName: 'notification',
                        title: AppLocalizations.of(context).notifications,
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            // TODO: Toggle notifications
                          },
                          activeColor: AppColors.primary,
                        ),
                        onTap: null,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingLG.h),
                  _MenuSection(
                    items: [
                      _MenuItem(
                        iconName: 'help',
                        title: AppLocalizations.of(context).help,
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                      _MenuItem(
                        iconName: 'info',
                        title: AppLocalizations.of(context).about,
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingXL.h),
                  // Version
                  Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  SizedBox(height: AppSizes.paddingXL.h),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          return Container(
            padding: EdgeInsets.all(AppSizes.paddingMD.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const CustomIcon(name: 'logout', size: 20, color: AppColors.error),
                  label: Text(
                  AppLocalizations.of(context).logout,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMD.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.language_rounded, color: AppColors.primary),
            SizedBox(width: 12.w),
            Text('Tilni tanlang'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('O\'zbekcha'),
              value: 'uz',
              groupValue: 'uz',
              activeColor: AppColors.primary,
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('Русский'),
              value: 'ru',
              groupValue: 'uz',
              activeColor: AppColors.primary,
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('English'),
              value: 'en',
              groupValue: 'uz',
              activeColor: AppColors.primary,
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeCubit themeCubit, ThemeMode currentTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.palette_rounded, color: AppColors.primary),
            SizedBox(width: 12.w),
            Text('Mavzuni tanlang'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  Icon(Icons.light_mode_rounded, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text('Yorug\''),
                ],
              ),
              value: ThemeMode.light,
              groupValue: currentTheme,
              activeColor: AppColors.primary,
              onChanged: (value) {
                themeCubit.changeTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  Icon(Icons.dark_mode_rounded, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text('Qorong\'i'),
                ],
              ),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              activeColor: AppColors.primary,
              onChanged: (value) {
                themeCubit.changeTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  Icon(Icons.settings_suggest_rounded, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text('Tizim'),
                ],
              ),
              value: ThemeMode.system,
              groupValue: currentTheme,
              activeColor: AppColors.primary,
              onChanged: (value) {
                themeCubit.changeTheme(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).logout),
        content: Text('Haqiqatan ham chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/phone-login');
            },
            child: Text(
              AppLocalizations.of(context).logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).appName),
        content:  Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).appTagline),
            SizedBox(height: AppSizes.spaceMD),
            Text('Version: 1.0.0'),
            SizedBox(height: AppSizes.spaceSM),
            Text('© 2025 Gold Imperia'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String? photoUrl;

  const _ProfileHeader({
    required this.name,
    required this.phoneNumber,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: AppColors.textOnPrimary,
                  ),
          ),
          SizedBox(height: AppSizes.paddingMD.h),
          // Name
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSizes.paddingXS.h),
          // Phone
          Text(
            phoneNumber,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];
            return Column(
              children: [
                if (index > 0) const Divider(height: 1),
                ListTile(
                  leading: item.iconName != null 
                      ? CustomIcon(
                          name: item.iconName!,
                          size: 24,
                          color: AppColors.primary,
                        )
                      : Icon(
                          item.icon,
                          color: AppColors.primary,
                        ),
                  title: Text(item.title),
                  trailing: item.trailing ??
                      (item.onTap != null
                          ? const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            )
                          : null),
                  onTap: item.onTap,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData? icon;
  final String? iconName; // Custom SVG icon name
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuItem({
    this.icon,
    this.iconName,
    required this.title,
    this.trailing,
    this.onTap,
  }) : assert(icon != null || iconName != null, 'Either icon or iconName must be provided');
}
