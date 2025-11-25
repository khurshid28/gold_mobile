import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/store.dart';
import '../../../installment/presentation/pages/contract_page.dart';
import '../../../installment/presentation/widgets/pin_verification_bottom_sheet.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  final List<Store> stores = Store.mockStores;

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
          return _StoreCard(store: store, isDark: isDark);
        },
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Store store;
  final bool isDark;

  const _StoreCard({
    required this.store,
    required this.isDark,
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
                          _showRasmiylashtirish(context);
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

  void _showRasmiylashtirish(BuildContext context) {
    // Sample jewelry item for store purchase
    const productName = 'Tilla uzuk';
    const productPrice = 5000000.0;
    const selectedMonths = 12;
    const monthlyPayment = productPrice / selectedMonths;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'store', color: AppColors.gold),
            SizedBox(width: 12.w),
            Text('Rasmiylashtirish'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do\'kon: ${store.name}'),
            SizedBox(height: 8.h),
            Text(
              'Mahsulotni do\'konda tanlab, bo\'lib to\'lash shartnomasi tuzishingiz mumkin.',
              style: TextStyle(fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIcon(name: 'info', color: AppColors.info, size: 20),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Shartnoma va tasdiqlash kodi yuboriladi',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContractPage(context, productName, productPrice, selectedMonths, monthlyPayment);
            },
            child: const Text('Davom etish'),
          ),
        ],
      ),
    );
  }

  void _showContractPage(BuildContext context, String productName, double productPrice, int selectedMonths, double monthlyPayment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(
          productName: productName,
          productPrice: productPrice,
          selectedMonths: selectedMonths,
          monthlyPayment: monthlyPayment,
          onAgree: () {
            _showPinVerificationBottomSheet(context);
          },
        ),
      ),
    );
  }

  void _showPinVerificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PinVerificationBottomSheet(
        isDark: isDark,
        onVerified: () {
          Navigator.pop(context);
          _showSuccessDialog(context);
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIcon(
                name: 'check_circle',
                color: AppColors.success,
                size: 50,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Muvaffaqiyatli!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Bo\'lib to\'lash shartnomasi tuzildi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              store.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.push('/my-purchases');
              },
              child: const Text('Mening haridlarimga o\'tish'),
            ),
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
