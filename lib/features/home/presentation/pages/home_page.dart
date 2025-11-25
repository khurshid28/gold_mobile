import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/constants/app_sizes.dart';
import 'package:gold_mobile/core/constants/app_strings.dart';
import 'package:gold_mobile/core/widgets/custom_icon.dart';
import 'package:gold_mobile/core/widgets/product_card.dart';
import 'package:gold_mobile/core/widgets/shimmer_widgets.dart';
import 'package:gold_mobile/features/home/domain/entities/category.dart';
import 'package:gold_mobile/features/home/domain/entities/jewelry_item.dart';
import 'package:gold_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:gold_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:gold_mobile/features/home/presentation/bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.cardBackgroundDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(4.w),
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const CustomIcon(name: 'search', size: 24),
            onPressed: () {
              context.push('/search');
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const _LoadingView();
          } else if (state is HomeLoaded) {
            return _HomeContent(
              categories: state.categories,
              featuredItems: state.featuredItems,
              newArrivals: state.newArrivals,
              bestSellers: state.bestSellers,
            );
          } else if (state is HomeError) {
            return _ErrorView(message: state.message);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: AppSizes.paddingMD.h),
          const CategoryShimmer(),
          SizedBox(height: AppSizes.paddingLG.h),
          const ProductGridShimmer(),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: AppSizes.paddingMD.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.paddingLG.h),
          ElevatedButton(
            onPressed: () {
              context.read<HomeBloc>().add(LoadHomeData());
            },
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final List<Category> categories;
  final List<JewelryItem> featuredItems;
  final List<JewelryItem> newArrivals;
  final List<JewelryItem> bestSellers;

  const _HomeContent({
    required this.categories,
    required this.featuredItems,
    required this.newArrivals,
    required this.bestSellers,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSizes.paddingSM.h),
            // Categories
            _SectionHeader(
              title: AppStrings.categories,
              onViewAll: () {
                context.push('/search');
              },
            ),
            SizedBox(height: AppSizes.paddingMD.h),
            _CategoriesList(categories: categories),
            SizedBox(height: AppSizes.paddingXL.h),
            // Featured Items
            if (featuredItems.isNotEmpty) ...[
              _SectionHeader(
                title: AppStrings.featured,
                onViewAll: () {
                  context.push('/search');
                },
              ),
              SizedBox(height: AppSizes.paddingMD.h),
              _HorizontalProductList(items: featuredItems),
              SizedBox(height: AppSizes.paddingXL.h),
            ],
            // New Arrivals
            _SectionHeader(
              title: AppStrings.newArrivals,
              onViewAll: () {
                context.push('/search');
              },
            ),
            SizedBox(height: AppSizes.paddingMD.h),
            _HorizontalProductList(items: newArrivals),
            SizedBox(height: AppSizes.paddingXL.h),
            // Best Sellers
            _SectionHeader(
              title: AppStrings.bestSellers,
              onViewAll: () {
                context.push('/search');
              },
            ),
            SizedBox(height: AppSizes.paddingMD.h),
            _ProductGrid(items: bestSellers),
            SizedBox(height: AppSizes.paddingXL.h),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text(AppStrings.viewAll),
            ),
        ],
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final List<Category> categories;

  const _CategoriesList({required this.categories});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              context.push('/category', extra: category);
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.only(right: AppSizes.paddingMD.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: category.iconPath,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight,
                          child: const Center(
                            child: Icon(
                              Icons.image_rounded,
                              color: AppColors.gold,
                              size: 28,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight,
                          child: const Center(
                            child: Icon(
                              Icons.image_rounded,
                              color: AppColors.gold,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.sp),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalProductList extends StatelessWidget {
  final List<JewelryItem> items;

  const _HorizontalProductList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 255,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 180,
            margin: EdgeInsets.only(right: 16.w),
            child: ProductCard(
              item: item,
              onTap: () {
                context.push('/product-detail', extra: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<JewelryItem> items;

  const _ProductGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ProductCard(
          item: item,
          onTap: () {
            context.push('/product-detail', extra: item);
          },
        );
      },
    );
  }
}
