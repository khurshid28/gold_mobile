import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/store.dart';
import 'installment_selection_page.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  final List<Store> stores = Store.mockStores;
  bool _isVerified = false;
  double? _creditLimit;
  DateTime? _limitExpiryDate;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isVerified = prefs.getBool('isVerified') ?? false;
        _creditLimit = prefs.getDouble('creditLimit');
        final expiryString = prefs.getString('limitExpiryDate');
        if (expiryString != null) {
          _limitExpiryDate = DateTime.parse(expiryString);
          // Check if expired
          if (_limitExpiryDate!.isBefore(DateTime.now())) {
            _creditLimit = null;
            _limitExpiryDate = null;
          }
        }
      });
    }
  }

  bool get _hasActiveLimit {
    if (_creditLimit == null || _limitExpiryDate == null) return false;
    return _limitExpiryDate!.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackgroundDark : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: CustomIcon(
              name: 'back',
              size: 20,
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
        ),
        title: Text(
          'Bizning do\'konlarimiz',
          style: TextStyle(
            fontSize: AppSizes.fontLG.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSizes.paddingLG.w),
        itemCount: stores.length,
        separatorBuilder: (context, index) => SizedBox(height: AppSizes.paddingLG.h),
        itemBuilder: (context, index) {
          final store = stores[index];
          return _StoreCard(
            store: store,
            isDark: isDark,
            isVerified: _isVerified,
            hasActiveLimit: _hasActiveLimit,
            onNeedReload: () => _loadVerificationStatus(),
          );
        },
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Store store;
  final bool isDark;
  final bool isVerified;
  final bool hasActiveLimit;
  final VoidCallback onNeedReload;

  const _StoreCard({
    required this.store,
    required this.isDark,
    required this.isVerified,
    required this.hasActiveLimit,
    required this.onNeedReload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store image
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLG.r),
            ),
            child: CachedNetworkImage(
              imageUrl: store.imageUrl,
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight,
                child: const Center(
                  child: LoadingWidget(
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight,
                child: CustomIcon(
                  name: 'store',
                  size: 64,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store name
                Text(
                  store.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 10.h),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIcon(
                      name: 'location',
                      size: 18.sp,
                      color: AppColors.gold,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        store.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Phone
                Row(
                  children: [
                    CustomIcon(
                      name: 'phone',
                      size: 18.sp,
                      color: AppColors.gold,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        store.phoneNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Working hours
                Row(
                  children: [
                    CustomIcon(
                      name: 'clock',
                      size: 18.sp,
                      color: AppColors.gold,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        store.workingHours,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Features
                Row(
                  children: [
                    if (store.hasParking) ...[
                      _FeatureChip(
                        icon: Icons.local_parking_rounded,
                        label: 'Parking',
                        isDark: isDark,
                      ),
                      SizedBox(width: AppSizes.paddingSM.w),
                    ],
                    if (store.hasAccessibility)
                      _FeatureChip(
                        icon: Icons.accessible_rounded,
                        label: 'Accessibility',
                        isDark: isDark,
                      ),
                  ],
                ),
                SizedBox(height: AppSizes.paddingMD.h),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Open map with directions
                          // Can use url_launcher with geo: URL
                        },
                        icon: CustomIcon(name: 'location', size: 18),
                        label: Text(
                          'Yo\'nalish',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _handleRasmiylashtirish(context);
                        },
                        icon: CustomIcon(name: 'check_circle', size: 18),
                        label: Text(
                          'Rasmiylashtirish',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleRasmiylashtirish(BuildContext context) {
    // Check if verified
    if (!isVerified) {
      _showVerificationRequiredDialog(context);
      return;
    }
    
    // Check if has active limit
    if (!hasActiveLimit) {
      _showLimitRequiredDialog(context);
      return;
    }
    
    // Navigate to installment selection page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstallmentSelectionPage(
          store: store,
          onSuccess: () {
            onNeedReload();
            context.push('/my-purchases');
          },
        ),
      ),
    );
  }

  void _showVerificationRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'info', color: AppColors.warning),
            SizedBox(width: 12.w),
            Text('Shaxsni tasdiqlang'),
          ],
        ),
        content: Text(
          'Bo\'lib to\'lashdan foydalanish uchun avval shaxsingizni tasdiqlashingiz kerak.',
          style: TextStyle(
            color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.push('/profile');
              onNeedReload();
            },
            child: const Text('Profilga o\'tish'),
          ),
        ],
      ),
    );
  }

  void _showLimitRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'info', color: AppColors.warning),
            SizedBox(width: 12.w),
            Text('Limit kerak'),
          ],
        ),
        content: Text(
          'Bo\'lib to\'lashdan foydalanish uchun kredit limitingizni tekshirishingiz kerak.',
          style: TextStyle(
            color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.push('/profile');
              onNeedReload();
            },
            child: const Text('Limitni tekshirish'),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSM.w,
        vertical: AppSizes.paddingXS.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: AppColors.gold,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontXS.sp,
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
