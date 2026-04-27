import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_sizes.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardBackgroundDark : AppColors.shimmerBase,
      highlightColor: isDark 
          ? AppColors.cardBackgroundDark.withOpacity(0.5)
          : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackgroundDark : AppColors.shimmerBase,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMD),
        ),
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: EdgeInsets.only(right: AppSizes.paddingMD.w),
            child: Column(
              children: [
                ShimmerWidget(
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull.r)),
                ),
                SizedBox(height: AppSizes.paddingSM.h),
                ShimmerWidget(
                  width: 60,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusMD.r),
              topRight: Radius.circular(AppSizes.radiusMD.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingSM.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: AppSizes.paddingSM.h),
                ShimmerWidget(
                  width: 80,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSizes.paddingMD.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSizes.gridSpacing.w,
        mainAxisSpacing: AppSizes.gridSpacing.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardShimmer(),
    );
  }
}

/// Shimmer for the [HomeWalletStrip] block on the home page.
class WalletStripShimmer extends StatelessWidget {
  const WalletStripShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
          child: ShimmerWidget(
            width: double.infinity,
            height: 78.h,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        SizedBox(height: 14.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w + 6),
          child: ShimmerWidget(
            width: double.infinity,
            height: 134.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: ShimmerWidget(
                  width: i == 0 ? 16.w : 6.w,
                  height: 6.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Section header shimmer (title + "see all").
class SectionHeaderShimmer extends StatelessWidget {
  const SectionHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerWidget(
              width: 130.w,
              height: 18.h,
              borderRadius: BorderRadius.circular(4.r)),
          ShimmerWidget(
              width: 60.w,
              height: 14.h,
              borderRadius: BorderRadius.circular(4.r)),
        ],
      ),
    );
  }
}

/// Horizontal product list shimmer (used for featured / new arrivals).
class HorizontalProductsShimmer extends StatelessWidget {
  const HorizontalProductsShimmer({super.key, this.itemCount = 4});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          width: 150.w,
          margin: EdgeInsets.only(right: AppSizes.paddingMD.w),
          child: const ProductCardShimmer(),
        ),
      ),
    );
  }
}
