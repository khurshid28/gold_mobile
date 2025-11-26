import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_sizes.dart';
import 'package:gold_mobile/core/l10n/app_localizations.dart';
import 'package:gold_mobile/core/theme/theme_cubit.dart';
import 'package:gold_mobile/core/widgets/custom_icon.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'identity_verification_page.dart';
import 'credit_limit_check_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _pendingPurchasesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingPurchasesCount();
  }

  Future<void> _loadPendingPurchasesCount() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasesJson = prefs.getStringList('my_purchases') ?? [];

    print('DEBUG: Total purchases found: ${purchasesJson.length}');
    
    int pendingCount = 0;
    for (final json in purchasesJson) {
      final purchase = jsonDecode(json);
      print('DEBUG: Purchase status: ${purchase['status']}');
      if (purchase['status'] == 'pending') {
        pendingCount++;
      }
    }

    print('DEBUG: Pending count: $pendingCount');

    if (mounted) {
      setState(() {
        _pendingPurchasesCount = pendingCount;
      });
    }
  }

  bool _hasActiveLimit(double? creditLimit, DateTime? limitExpiryDate) {
    if (creditLimit == null || limitExpiryDate == null) return false;
    return limitExpiryDate.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final currentTheme = themeCubit.state;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).profile)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Force rebuild when state changes
          print('DEBUG: AuthBloc state changed - ${state.runtimeType}');
          if (state is AuthAuthenticated) {
            print(
              'DEBUG: User data - name: ${state.user.name}, verified: ${state.user.isVerified}',
            );
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            final hasActiveLimit = _hasActiveLimit(
              user.creditLimit,
              user.limitExpiryDate,
            );

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: AppSizes.paddingMD.h),
                  // Profile Header
                  _ProfileHeader(
                    name: user.name ?? 'Foydalanuvchi',
                    phoneNumber: state.user.phoneNumber,
                    photoUrl: state.user.photoUrl,
                    isVerified: user.isVerified,
                  ),
                  SizedBox(height: AppSizes.paddingXL.h),

                  // Verification and Limit Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMD.w,
                    ),
                    child: Column(
                      children: [
                        if (!user.isVerified)
                          _VerificationCard(
                            onTap: () async {
                              // Identity + Face Verification
                              final result =
                                  await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const IdentityVerificationPage(),
                                    ),
                                  );

                              if (result != null &&
                                  result['verified'] == true &&
                                  mounted) {
                                // Mark as verified and update name immediately
                                print(
                                  'DEBUG: Updating profile - verified: true, name: ${result['name']}',
                                );
                                context.read<AuthBloc>().add(
                                  UpdateUserProfile(
                                    isVerified: true,
                                    name: result['name'] as String?,
                                  ),
                                );

                                // Small delay to ensure state updates
                                await Future.delayed(
                                  const Duration(milliseconds: 200),
                                );

                                print(
                                  'DEBUG: Action type: ${result['action']}',
                                );

                                if (!mounted) return;

                                // Check if user clicked "Davom etish" (went through video)
                                if (result['action'] == 'continue') {
                                  // Navigate to credit limit check
                                  final limitResult =
                                      await Navigator.push<
                                        Map<String, dynamic>
                                      >(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreditLimitCheckPage(),
                                        ),
                                      );
                                  if (limitResult != null && mounted) {
                                    context.read<AuthBloc>().add(
                                      UpdateUserProfile(
                                        creditLimit: limitResult['limit'],
                                        limitExpiryDate:
                                            limitResult['expiryDate'],
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        if (user.isVerified && !hasActiveLimit) ...[
                          SizedBox(height: AppSizes.paddingMD.h),
                          _LimitCheckCard(
                            onTap: () async {
                              final result =
                                  await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreditLimitCheckPage(),
                                    ),
                                  );
                              if (result != null && mounted) {
                                context.read<AuthBloc>().add(
                                  UpdateUserProfile(
                                    creditLimit: result['limit'],
                                    limitExpiryDate: result['expiryDate'],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                        if (user.isVerified && hasActiveLimit) ...[
                          SizedBox(height: AppSizes.paddingMD.h),
                          _ActiveLimitCard(
                            totalLimit: user.creditLimit!,
                            usedLimit: user.usedLimit ?? 0.0,
                            expiryDate: user.limitExpiryDate!,
                          ),
                        ],
                        SizedBox(height: AppSizes.paddingLG.h),
                      ],
                    ),
                  ),

                  // Menu Items
                  _MenuSection(
                    items: [
                      _MenuItem(
                        iconName: 'shopping_bag',
                        title: AppLocalizations.of(context).myPurchases,
                        badgeCount: _pendingPurchasesCount,
                        onTap: () async {
                          await context.push('/my-purchases');
                          // Reload pending count when returning
                          _loadPendingPurchasesCount();
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
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                              size: 20.sp,
                            ),
                          ],
                        ),
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                      ),
                      _MenuItem(
                        icon: currentTheme == ThemeMode.light
                            ? Icons.light_mode_rounded
                            : currentTheme == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : Icons.settings_suggest_rounded,
                        title: 'Mavzu',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentTheme == ThemeMode.light
                                  ? 'Yorug\''
                                  : currentTheme == ThemeMode.dark
                                  ? 'Qorong\'i'
                                  : 'Tizim',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                              size: 20.sp,
                            ),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
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
                icon: const CustomIcon(
                  name: 'logout',
                  size: 20,
                  color: AppColors.error,
                ),
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

  void _showThemeDialog(
    BuildContext context,
    ThemeCubit themeCubit,
    ThemeMode currentTheme,
  ) {
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
        content: Column(
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
  final bool isVerified;

  const _ProfileHeader({
    required this.name,
    required this.phoneNumber,
    this.photoUrl,
    this.isVerified = false,
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
                colors: [AppColors.primary, AppColors.primaryLight],
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
                ? ClipOval(child: Image.network(photoUrl!, fit: BoxFit.cover))
                : const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: AppColors.textOnPrimary,
                  ),
          ),
          SizedBox(height: AppSizes.paddingMD.h),
          // Name with verification badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: Theme.of(context).textTheme.headlineMedium),
              if (isVerified) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.verified,
                  color: Color(0xFF1DA1F2), // Instagram/Telegram blue
                  size: 24.sp,
                ),
              ],
            ],
          ),
          SizedBox(height: AppSizes.paddingXS.h),
          // Phone
          Text(
            phoneNumber,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
        children: List.generate(items.length, (index) {
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
                    : Icon(item.icon, color: AppColors.primary),
                title: Row(
                  children: [
                    Text(item.title),
                    if (item.badgeCount != null && item.badgeCount! > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${item.badgeCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing:
                    item.trailing ??
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
        }),
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
  final int? badgeCount;

  _MenuItem({
    this.icon,
    this.iconName,
    required this.title,
    this.trailing,
    this.onTap,
    this.badgeCount,
  }) : assert(
         icon != null || iconName != null,
         'Either icon or iconName must be provided',
       );
}

class _VerificationCard extends StatelessWidget {
  final VoidCallback onTap;

  const _VerificationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.info.withOpacity(0.1),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.face, color: AppColors.info, size: 24),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shaxsingizni tasdiqlang',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Hujjat va yuzni tasdiqlang',
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
            Icon(Icons.chevron_right_rounded, color: AppColors.info),
          ],
        ),
      ),
    );
  }
}

class _LimitCheckCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LimitCheckCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withOpacity(0.1),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIcon(
                name: 'wallet',
                color: AppColors.gold,
                size: 24,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Limitni tekshirish',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Karta orqali limitni aniqlang',
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
            Icon(Icons.chevron_right_rounded, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

class _ActiveLimitCard extends StatelessWidget {
  final double totalLimit;
  final double usedLimit;
  final DateTime expiryDate;

  const _ActiveLimitCard({
    required this.totalLimit,
    required this.usedLimit,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final difference = expiryDate.difference(DateTime.now());
    final daysLeft = difference.inDays;
    final hoursLeft = difference.inHours % 24;
    final availableLimit = totalLimit - usedLimit;
    final usedPercentage = totalLimit > 0 ? (usedLimit / totalLimit * 100) : 0;

    String timeLeftText;
    if (daysLeft > 0) {
      timeLeftText = '$daysLeft kun';
    } else {
      timeLeftText = '$hoursLeft soat';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIcon(
                name: 'check_circle',
                color: AppColors.success,
                size: 24,
              ),
              SizedBox(width: 8.w),
              Text(
                'Aktiv limit',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '${formatter.format(availableLimit)} so\'m',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Mavjud / Jami: ${formatter.format(totalLimit)} so\'m',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
            ),
          ),
          if (usedLimit > 0) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: usedPercentage / 100,
                    backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                    color: usedPercentage > 80
                        ? AppColors.error
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${usedPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMediumOnDark
                        : AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            children: [
              CustomIcon(
                name: 'clock',
                color: AppColors.textSecondary,
                size: 16,
              ),
              SizedBox(width: 6.w),
              Text(
                'Amal qilish muddati: $timeLeftText',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textMediumOnDark
                      : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
