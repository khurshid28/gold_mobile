import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/card_otp_page.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/card_picker.dart';

// =============================================================================
// Catalog
// =============================================================================
class _Provider {
  final String name;
  final String shortLabel;
  final Color color;
  final String? assetPath;
  final IconData? fallbackIcon;
  const _Provider(
    this.name,
    this.shortLabel,
    this.color, {
    this.assetPath,
    this.fallbackIcon,
  });
}

enum _AccountKind { phone, contract }

String _a(String file) => 'assets/images/providers/$file';

class _Category {
  final String name;
  final IconData icon;
  final Color color;
  final String accountHint;
  final String accountLabel;
  final _AccountKind accountKind;
  final List<_Provider> providers;
  const _Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.accountHint,
    required this.accountLabel,
    required this.providers,
    this.accountKind = _AccountKind.contract,
  });
}

final _categories = <_Category>[
  _Category(
    name: 'Mobil aloqa',
    icon: IconsaxPlusBold.mobile,
    color: const Color(0xFF1565C0),
    accountLabel: 'Telefon raqami',
    accountHint: '+998 90 123 45 67',
    accountKind: _AccountKind.phone,
    providers: [
      _Provider('Uzmobile', 'UZ', const Color(0xFF1769FF),
          assetPath: _a('uzmobile.png')),
      _Provider('Beeline', 'B', const Color(0xFFFFC107),
          assetPath: _a('beeline.png')),
      _Provider('Ucell', 'U', const Color(0xFF7B1FA2),
          assetPath: _a('ucell.png')),
      _Provider('Mobiuz', 'M', const Color(0xFFE53935),
          assetPath: _a('mobiuz.png')),
      _Provider('Humans', 'H', const Color(0xFF00897B),
          fallbackIcon: IconsaxPlusBold.user),
      _Provider('Perfectum', 'P', const Color(0xFF455A64),
          fallbackIcon: IconsaxPlusBold.call),
    ],
  ),
  _Category(
    name: 'Internet',
    icon: IconsaxPlusBold.wifi,
    color: const Color(0xFF6A1B9A),
    accountLabel: 'Shartnoma raqami',
    accountHint: '00000000',
    providers: [
      _Provider('Uzonline', 'UO', const Color(0xFF0277BD),
          assetPath: _a('uzonline.png')),
      _Provider('TPS', 'TPS', const Color(0xFFEF6C00),
          assetPath: _a('tps.png')),
      _Provider('Sarkor Telekom', 'ST', const Color(0xFFD32F2F),
          assetPath: _a('sarkor.png')),
      _Provider('East Telekom', 'ET', const Color(0xFF388E3C),
          assetPath: _a('east.png')),
      _Provider('Comnet', 'CN', const Color(0xFF512DA8),
          assetPath: _a('comnet.png')),
      _Provider('Sharq', 'SH', const Color(0xFF00838F),
          assetPath: _a('sharq.png')),
    ],
  ),
  _Category(
    name: 'Kommunal',
    icon: IconsaxPlusBold.flash_1,
    color: const Color(0xFFEF6C00),
    accountLabel: 'Shaxsiy hisob',
    accountHint: '0000000000',
    providers: [
      _Provider('Elektr energiya', 'E', const Color(0xFFFFB300),
          fallbackIcon: IconsaxPlusBold.flash_1),
      _Provider('Gaz', 'G', const Color(0xFF1976D2),
          fallbackIcon: IconsaxPlusBold.gas_station),
      _Provider('Sovuq suv', 'SS', const Color(0xFF0288D1),
          fallbackIcon: IconsaxPlusBold.drop),
      _Provider('Issiq suv', 'IS', const Color(0xFFE53935),
          assetPath: _a('iet.png')),
      _Provider('Isitish', 'IS', const Color(0xFFD84315),
          assetPath: _a('iet.png')),
      _Provider('Chiqindi', 'CH', const Color(0xFF6D4C41),
          fallbackIcon: IconsaxPlusBold.trash),
    ],
  ),
  _Category(
    name: 'TV',
    icon: IconsaxPlusBold.monitor,
    color: const Color(0xFF2E7D32),
    accountLabel: 'Hisob raqami',
    accountHint: '0000000000',
    providers: [
      _Provider('Uzdigital TV', 'UD', const Color(0xFF1976D2),
          assetPath: _a('uzdigital.png')),
      _Provider('Sarkor TV', 'ST', const Color(0xFFD32F2F),
          assetPath: _a('sarkor.png')),
      _Provider('Comnet TV', 'CN', const Color(0xFF512DA8),
          assetPath: _a('comnet.png')),
      _Provider('Online TV', 'OT', const Color(0xFF00897B),
          fallbackIcon: IconsaxPlusBold.video),
    ],
  ),
  _Category(
    name: 'Taksi',
    icon: IconsaxPlusBold.car,
    color: const Color(0xFFD32F2F),
    accountLabel: 'Telefon raqami',
    accountHint: '+998 90 123 45 67',
    accountKind: _AccountKind.phone,
    providers: [
      _Provider('Yandex Go', 'Y', const Color(0xFFFFCC00),
          assetPath: _a('yandex.png')),
      _Provider('MyTaxi', 'MT', const Color(0xFFE53935),
          assetPath: _a('mytaxi.png')),
      _Provider('UzTaxi', 'UT', const Color(0xFF1976D2),
          fallbackIcon: IconsaxPlusBold.car),
      _Provider('Express24', 'E24', const Color(0xFFEF6C00),
          assetPath: _a('express24.png')),
    ],
  ),
  _Category(
    name: 'Yetkazib berish',
    icon: IconsaxPlusBold.box,
    color: const Color(0xFF00838F),
    accountLabel: 'Buyurtma raqami',
    accountHint: '0000000000',
    providers: [
      _Provider('Express24', 'E24', const Color(0xFFEF6C00),
          assetPath: _a('express24.png')),
      _Provider('Wolt', 'W', const Color(0xFF00C2E8),
          assetPath: _a('wolt.png')),
      _Provider('Yandex Eda', 'YE', const Color(0xFFFFCC00),
          assetPath: _a('yandexeda.png')),
      _Provider('Lebazar', 'LB', const Color(0xFF7B1FA2),
          fallbackIcon: IconsaxPlusBold.shop),
      _Provider('Uzum Tezkor', 'UT', const Color(0xFF6A1B9A),
          assetPath: _a('uzum.png')),
    ],
  ),
  // ---------------------------------------------------------------
  _Category(
    name: 'Aviabilet',
    icon: IconsaxPlusBold.airplane,
    color: const Color(0xFF1976D2),
    accountLabel: 'Bron raqami',
    accountHint: 'ABC123',
    providers: [
      _Provider('Uzbekistan Airways', 'UA', const Color(0xFF0D47A1),
          fallbackIcon: IconsaxPlusBold.airplane),
      _Provider('Aviasales', 'AS', const Color(0xFFF57C00),
          fallbackIcon: IconsaxPlusBold.search_normal_1),
      _Provider('MyAirport', 'MA', const Color(0xFF00897B),
          fallbackIcon: IconsaxPlusBold.airplane_square),
    ],
  ),
  _Category(
    name: 'Poyezd',
    icon: IconsaxPlusBold.bus,
    color: const Color(0xFF455A64),
    accountLabel: 'Bilet raqami',
    accountHint: '0000000000',
    providers: [
      _Provider('UTY', 'UTY', const Color(0xFF1565C0),
          fallbackIcon: IconsaxPlusBold.bus),
      _Provider('Afrosiyob', 'AF', const Color(0xFFD32F2F),
          fallbackIcon: IconsaxPlusBold.routing),
      _Provider('Sharq', 'SH', const Color(0xFF6A1B9A),
          fallbackIcon: IconsaxPlusBold.routing_2),
    ],
  ),
  _Category(
    name: 'Davlat xizmatlari',
    icon: IconsaxPlusBold.security_safe,
    color: const Color(0xFF2E7D32),
    accountLabel: 'Shaxsiy hisob',
    accountHint: '00000000000000',
    providers: [
      _Provider('Soliq', 'SO', const Color(0xFF1B5E20),
          fallbackIcon: IconsaxPlusBold.receipt_2),
      _Provider('MIB', 'MIB', const Color(0xFF0D47A1),
          fallbackIcon: IconsaxPlusBold.security_user),
      _Provider('YHXBB Jarima', 'JR', const Color(0xFFD32F2F),
          fallbackIcon: IconsaxPlusBold.danger),
      _Provider('Sud ijro', 'SI', const Color(0xFF4527A0),
          fallbackIcon: IconsaxPlusBold.judge),
      _Provider('Bojxona', 'BX', const Color(0xFF00695C),
          fallbackIcon: IconsaxPlusBold.box_2),
    ],
  ),
  _Category(
    name: 'Ta\'lim',
    icon: IconsaxPlusBold.book_1,
    color: const Color(0xFF6D4C41),
    accountLabel: 'Talaba ID',
    accountHint: '0000000000',
    providers: [
      _Provider('TATU', 'T', const Color(0xFF1976D2),
          fallbackIcon: IconsaxPlusBold.teacher),
      _Provider('TUIT', 'TU', const Color(0xFF388E3C),
          fallbackIcon: IconsaxPlusBold.book_saved),
      _Provider('TIU', 'TI', const Color(0xFFEF6C00),
          fallbackIcon: IconsaxPlusBold.note_1),
      _Provider('Inha University', 'IU', const Color(0xFF0277BD),
          fallbackIcon: IconsaxPlusBold.bookmark),
      _Provider('WIUT', 'W', const Color(0xFF6A1B9A),
          fallbackIcon: IconsaxPlusBold.book),
    ],
  ),
  _Category(
    name: 'Bank kreditlari',
    icon: IconsaxPlusBold.bank,
    color: const Color(0xFFEF6C00),
    accountLabel: 'Shartnoma raqami',
    accountHint: '00000000',
    providers: [
      _Provider('Uzum Bank', 'UB', const Color(0xFF6A1B9A),
          assetPath: _a('uzum.png')),
      _Provider('Anorbank', 'AN', const Color(0xFFE91E63),
          fallbackIcon: IconsaxPlusBold.bank),
      _Provider('TBC Bank', 'TBC', const Color(0xFF1565C0),
          fallbackIcon: IconsaxPlusBold.bank),
      _Provider('Hamkorbank', 'HB', const Color(0xFF1B5E20),
          fallbackIcon: IconsaxPlusBold.bank),
      _Provider('Kapitalbank', 'KB', const Color(0xFFD32F2F),
          fallbackIcon: IconsaxPlusBold.bank),
      _Provider('Ipak Yo\'li', 'IY', const Color(0xFFEF6C00),
          fallbackIcon: IconsaxPlusBold.bank),
    ],
  ),
  _Category(
    name: 'Sug\'urta',
    icon: IconsaxPlusBold.shield_tick,
    color: const Color(0xFF00897B),
    accountLabel: 'Polis raqami',
    accountHint: '0000000000',
    providers: [
      _Provider('OSGO', 'O', const Color(0xFF00695C),
          fallbackIcon: IconsaxPlusBold.shield_tick),
      _Provider('Uzbekinvest', 'UI', const Color(0xFF0277BD),
          fallbackIcon: IconsaxPlusBold.security),
      _Provider('Gross Insurance', 'GI', const Color(0xFFD32F2F),
          fallbackIcon: IconsaxPlusBold.shield),
      _Provider('Apex Insurance', 'AI', const Color(0xFF6A1B9A),
          fallbackIcon: IconsaxPlusBold.shield_search),
    ],
  ),
  _Category(
    name: 'O\'yin va kontent',
    icon: IconsaxPlusBold.gameboy,
    color: const Color(0xFF7B1FA2),
    accountLabel: 'Login / ID',
    accountHint: 'username',
    providers: [
      _Provider('Steam', 'ST', const Color(0xFF1565C0),
          fallbackIcon: IconsaxPlusBold.gameboy),
      _Provider('PUBG Mobile', 'PUBG', const Color(0xFFEF6C00),
          fallbackIcon: IconsaxPlusBold.game),
      _Provider('Mobile Legends', 'ML', const Color(0xFF1976D2),
          fallbackIcon: IconsaxPlusBold.game),
      _Provider('Free Fire', 'FF', const Color(0xFFD32F2F),
          fallbackIcon: IconsaxPlusBold.flash_1),
      _Provider('Netflix', 'N', const Color(0xFFB71C1C),
          fallbackIcon: IconsaxPlusBold.video_play),
      _Provider('YouTube Premium', 'YT', const Color(0xFFD32F2F),
          fallbackIcon: IconsaxPlusBold.video),
      _Provider('Spotify', 'SP', const Color(0xFF1B5E20),
          fallbackIcon: IconsaxPlusBold.music),
      _Provider('Apple Music', 'AM', const Color(0xFF424242),
          fallbackIcon: IconsaxPlusBold.music_filter),
    ],
  ),
  _Category(
    name: 'Xayriya',
    icon: IconsaxPlusBold.heart,
    color: const Color(0xFFE91E63),
    accountLabel: 'Loyiha raqami',
    accountHint: '0000000000',
    providers: [
      _Provider('Ezgu Amal', 'EA', const Color(0xFFC2185B),
          fallbackIcon: IconsaxPlusBold.heart),
      _Provider('Sen Yolg\'iz Emassan', 'SE', const Color(0xFF6A1B9A),
          fallbackIcon: IconsaxPlusBold.heart_add),
      _Provider('UNICEF Uzbekistan', 'UN', const Color(0xFF0277BD),
          fallbackIcon: IconsaxPlusBold.global),
      _Provider('Mehribonlik uyi', 'MU', const Color(0xFF00695C),
          fallbackIcon: IconsaxPlusBold.home_2),
    ],
  ),
];

// =============================================================================
// Page 1: categories grid
// =============================================================================
class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key, required this.card});
  final BankCard card;

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(String value) =>
      value.toLowerCase().contains(_query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = widget.card;
    final hasQuery = _query.trim().isNotEmpty;
    final filteredCategories = hasQuery
        ? _categories.where((c) {
            if (_matches(c.name)) return true;
            return c.providers.any((p) => _matches(p.name));
          }).toList()
        : _categories;

    final providerMatches = hasQuery
        ? <({_Category c, _Provider p})>[
            for (final c in _categories)
              for (final p in c.providers)
                if (_matches(p.name)) (c: c, p: p),
          ]
        : const <({_Category c, _Provider p})>[];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('To\'lovlar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
            child: _SearchField(
              controller: _searchCtrl,
              hint: 'Xizmat yoki provayder qidirish...',
              isDark: isDark,
              onChanged: (v) => setState(() => _query = v),
              onClear: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
          ),
          Expanded(
            child: filteredCategories.isEmpty && providerMatches.isEmpty
                ? _EmptySearch(query: _query, isDark: isDark)
                : CustomScrollView(
                    slivers: [
                      if (providerMatches.isNotEmpty) ...[
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              16.w, 12.h, 16.w, 8.h),
                          sliver: SliverToBoxAdapter(
                            child: _SectionHeader(
                              title: 'Topilgan provayderlar',
                              count: providerMatches.length,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          sliver: SliverList.separated(
                            itemCount: providerMatches.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 8.h),
                            itemBuilder: (context, i) {
                              final m = providerMatches[i];
                              return _ProviderResultTile(
                                provider: m.p,
                                category: m.c,
                                isDark: isDark,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _PayPage(
                                      category: m.c,
                                      provider: m.p,
                                      card: card,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              16.w, 16.h, 16.w, 8.h),
                          sliver: SliverToBoxAdapter(
                            child: _SectionHeader(
                              title: 'Kategoriyalar',
                              count: filteredCategories.length,
                            ),
                          ),
                        ),
                      ],
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                            16.w, providerMatches.isEmpty ? 8.h : 0, 16.w, 20.h),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, i) {
                            final c = filteredCategories[i];
                            return _CategoryTile(
                              category: c,
                              isDark: isDark,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _ProvidersPage(
                                    category: c,
                                    card: card,
                                    initialQuery: _query,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.isDark,
    required this.onTap,
  });
  final _Category category;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = category;
    final dark = Color.lerp(c.color, Colors.black, 0.35)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: c.color.withOpacity(isDark ? 0.30 : 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.color, dark],
              ),
            ),
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.white.withOpacity(0.18),
              highlightColor: Colors.white.withOpacity(0.08),
              hoverColor: Colors.white.withOpacity(0.06),
              child: Stack(
                children: [
                  Positioned(
                    right: -10.w,
                    bottom: -10.h,
                    child: Icon(
                      c.icon,
                      size: 90.sp,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(c.icon,
                              color: Colors.white, size: 20.sp),
                        ),
                        Text(
                          c.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.isDark,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.textMediumOnDark
                : AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            IconsaxPlusLinear.search_normal_1,
            color: AppColors.gold,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    IconsaxPlusBold.close_circle,
                    color: AppColors.textMedium,
                    size: 20,
                  ),
                  onPressed: onClear,
                ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.14),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderResultTile extends StatelessWidget {
  const _ProviderResultTile({
    required this.provider,
    required this.category,
    required this.isDark,
    required this.onTap,
  });
  final _Provider provider;
  final _Category category;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.cardBackgroundDark : Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              _ProviderAvatar(provider: provider),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      category.name,
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
              const Icon(IconsaxPlusLinear.arrow_right_3,
                  color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query, required this.isDark});
  final String query;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconsaxPlusLinear.search_status_1,
                color: AppColors.gold,
                size: 40,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Hech narsa topilmadi',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '«$query» so\'rovi bo\'yicha xizmat yoki provayder topilmadi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.textMediumOnDark
                    : AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Page 2: providers list inside a category
// =============================================================================
class _ProvidersPage extends StatefulWidget {
  const _ProvidersPage({
    required this.category,
    required this.card,
    this.initialQuery = '',
  });
  final _Category category;
  final BankCard card;
  final String initialQuery;

  @override
  State<_ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<_ProvidersPage> {
  late final TextEditingController _searchCtrl =
      TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = widget.category;
    final card = widget.card;
    final q = _query.trim().toLowerCase();
    final providers = q.isEmpty
        ? category.providers
        : category.providers
            .where((p) => p.name.toLowerCase().contains(q))
            .toList();
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(category.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
            child: _SearchField(
              controller: _searchCtrl,
              hint: 'Provayder qidirish...',
              isDark: isDark,
              onChanged: (v) => setState(() => _query = v),
              onClear: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
          ),
          Expanded(
            child: providers.isEmpty
                ? _EmptySearch(query: _query, isDark: isDark)
                : ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, i) {
                      final p = providers[i];
                      return Material(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14.r),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => _PayPage(
                                category: category,
                                provider: p,
                                card: card,
                              ),
                            ));
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 12.h),
                            child: Row(
                              children: [
                                _ProviderAvatar(provider: p),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(IconsaxPlusLinear.arrow_right_3,
                                    color: AppColors.gold),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.provider});
  final _Provider provider;
  @override
  Widget build(BuildContext context) {
    final hasLogo = provider.assetPath != null;
    final fallbackBg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        provider.color,
        Color.lerp(provider.color, Colors.black, 0.35)!,
      ],
    );
    Widget fallback() => DecoratedBox(
          decoration: BoxDecoration(gradient: fallbackBg),
          child: Center(
            child: provider.fallbackIcon != null
                ? Icon(provider.fallbackIcon,
                    color: Colors.white, size: 24.sp)
                : Text(
                    provider.shortLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize:
                          provider.shortLabel.length > 2 ? 12.sp : 16.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: hasLogo ? Colors.white : null,
        gradient: hasLogo ? null : fallbackBg,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: provider.color.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasLogo
          ? Padding(
              padding: EdgeInsets.all(8.w),
              child: Image.asset(
                provider.assetPath!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => fallback(),
              ),
            )
          : fallback(),
    );
  }
}

// =============================================================================
// Pay page: account + amount + card
// =============================================================================
class _PayPage extends StatefulWidget {
  const _PayPage({
    required this.category,
    required this.provider,
    required this.card,
  });
  final _Category category;
  final _Provider provider;
  final BankCard card;

  @override
  State<_PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<_PayPage> {
  final _accountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  late BankCard _selectedCard = widget.card;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _pay() {
    final raw = _amountCtrl.text.replaceAll(RegExp(r'\s+'), '');
    final amount = double.tryParse(raw) ?? 0;
    if (_accountCtrl.text.trim().isEmpty || amount <= 0) {
      Fluttertoast.showToast(msg: 'Maydonlarni to\'ldiring');
      return;
    }
    if (amount > _selectedCard.balance) {
      Fluttertoast.showToast(
        msg: 'Kartada mablag\' yetarli emas',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }
    final merchant = '${widget.category.name} · ${widget.provider.name}';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WalletOtpPage(
        title: 'To\'lov',
        subtitle:
            '$merchant: ${MoneyFormat.sum(amount)} - tasdiqlash',
        onVerified: (ctx) async {
          final repo = ctx.read<WalletBloc>().repo;
          try {
            final res = await repo.payment(
              card: _selectedCard,
              amount: amount,
              merchant: merchant,
              merchantLogo: widget.provider.assetPath,
              note: _accountCtrl.text.trim(),
            );
            ctx.read<WalletBloc>().add(const LoadWallet());
            Navigator.of(ctx).pop(); // pop OTP
            Navigator.of(ctx).pop(); // pop pay page
            ctx.push('/wallet/receipt', extra: res.tx);
          } catch (e) {
            Fluttertoast.showToast(
              msg: e.toString().replaceAll('Exception: ', ''),
              backgroundColor: AppColors.error,
              textColor: Colors.white,
            );
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.provider.name),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          Row(
            children: [
              _ProviderAvatar(provider: widget.provider),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.provider.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.category.name,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _accountCtrl,
            keyboardType: widget.category.accountKind == _AccountKind.phone
                ? TextInputType.phone
                : TextInputType.number,
            inputFormatters: widget.category.accountKind == _AccountKind.phone
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                    _UzPhoneFormatter(),
                  ]
                : [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: widget.category.accountLabel,
              hintText: widget.category.accountHint,
              prefixIcon: Icon(
                widget.category.accountKind == _AccountKind.phone
                    ? IconsaxPlusLinear.call
                    : IconsaxPlusLinear.user,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Summa',
              prefixIcon: Icon(IconsaxPlusLinear.dollar_circle),
              suffixText: 'so\'m',
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Karta',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.textMedium,
            ),
          ),
          SizedBox(height: 8.h),
          CardPickerTile(
            selected: _selectedCard,
            onChanged: (c) => setState(() => _selectedCard = c),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
              ),
              child: Text(
                'To\'lash',
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final n = int.tryParse(digits) ?? 0;
    final formatted = MoneyFormat.amount(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Masks Uzbek phone numbers as: +998 90 123 45 67
class _UzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // If user typed leading 998 or 9 we just keep digits; ensure max 12.
    if (digits.startsWith('998')) {
      digits = digits.substring(3);
    }
    if (digits.length > 9) digits = digits.substring(0, 9);

    final buf = StringBuffer('+998');
    if (digits.isNotEmpty) {
      buf.write(' ');
      buf.write(digits.substring(0, digits.length.clamp(0, 2)));
    }
    if (digits.length > 2) {
      buf.write(' ');
      buf.write(digits.substring(2, digits.length.clamp(0, 5)));
    }
    if (digits.length > 5) {
      buf.write(' ');
      buf.write(digits.substring(5, digits.length.clamp(0, 7)));
    }
    if (digits.length > 7) {
      buf.write(' ');
      buf.write(digits.substring(7, digits.length.clamp(0, 9)));
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
