import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_sizes.dart';
import 'package:gold_mobile/core/widgets/shimmer_widgets.dart';
import 'package:gold_mobile/features/home/domain/entities/jewelry_item.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final JewelryItem item;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'uz_UZ');
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackgroundDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:  BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusMD),
                    topRight: Radius.circular(AppSizes.radiusMD),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.images.first,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>  ShimmerWidget(
                      width: double.infinity,
                      height: 110,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusMD),
                        topRight: Radius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 110,
                      color: AppColors.cardBackground,
                      child: const Icon(
                        Icons.diamond_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                // Discount Badge
                if (item.discount != null && item.discount! > 0)
                  Positioned(
                    top: AppSizes.paddingSM,
                    right: AppSizes.paddingSM,
                    child: Container(
                      padding:  EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSM,
                        vertical: AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      ),
                      child: Text(
                        '-${item.discount!.toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    // Category
                    Text(
                      item.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontSize: 10.sp,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price
                    if (item.discount != null && item.discount! > 0)
                      Text(
                        '${_formatPrice(item.price)} so\'m',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textLight,
                              fontSize: 9.sp,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      '${_formatPrice(item.finalPrice)} so\'m',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
