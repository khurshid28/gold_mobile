import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../home/domain/entities/jewelry_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/domain/entities/cart_item.dart';

class ProductDetailPage extends StatefulWidget {
  final JewelryItem item;

  const ProductDetailPage({super.key, required this.item});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.h,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            leading: IconButton(
              onPressed: () => context.pop(),
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
            actions: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardBackgroundDark : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const CustomIcon(name: 'favorite', size: 20, color: AppColors.primary),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${widget.item.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.item.images.isNotEmpty ? widget.item.images[0] : '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: LoadingWidget(
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingXL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Playfair',
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.paddingSM.h),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(widget.item.price)} so\'m',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            SizedBox(width: AppSizes.paddingSM.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingSM.w,
                                vertical: AppSizes.paddingXS.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
                              ),
                              child: Text(
                                widget.item.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.paddingXL.h),
                        
                        // Weight
                        _DetailItem(
                          iconName: 'weight',
                          label: 'Og\'irligi',
                          value: '${widget.item.weight}g',
                        ),
                        SizedBox(height: AppSizes.paddingLG.h),
                        
                        // Purity/Material
                        _DetailItem(
                          iconName: 'diamond',
                          label: 'Material',
                          value: widget.item.material,
                        ),
                        SizedBox(height: AppSizes.paddingLG.h),
                        
                        // Stock status
                        _DetailItem(
                          icon: Icons.inventory_rounded,
                          label: 'Holati',
                          value: widget.item.inStock ? 'Omborda bor' : 'Tugagan',
                          valueColor: widget.item.inStock ? Colors.green : Colors.red,
                        ),
                        SizedBox(height: AppSizes.paddingXXL.h),
                        
                        // Description
                        Text(
                          'Tavsif',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: AppSizes.paddingMD.h),
                        Text(
                          widget.item.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                        ),
                        SizedBox(height: AppSizes.paddingXXL.h * 1.5),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: widget.item.inStock
                                    ? () {
                                        context.push('/installment', extra: {
                                          'productId': widget.item.id,
                                          'productName': widget.item.name,
                                          'productImage': widget.item.images.isNotEmpty ? widget.item.images[0] : '',
                                          'productPrice': widget.item.price,
                                        });
                                      }
                                    : null,
                                icon: const CustomIcon(name: 'check_circle', size: 20),
                                label: const Text('Bo\'lib to\'lash'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMD.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSizes.paddingMD.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.item.inStock
                                    ? () {
                                        context.read<CartBloc>().add(
                                              AddToCart(
                                                CartItem(
                                                  item: widget.item,
                                                  quantity: 1,
                                                ),
                                              ),
                                            );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Savatga qo\'shildi'),
                                            duration: Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'Ko\'rish',
                                              onPressed: () {
                                                // Navigate back to home and switch to cart tab
                                                Navigator.of(context).popUntil((route) => route.isFirst);
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.shopping_cart_rounded),
                                label: const Text('Savatga'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMD.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.paddingLG.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData? icon;
  final String? iconName;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    this.icon,
    this.iconName,
    required this.label,
    required this.value,
    this.valueColor,
  }) : assert(icon != null || iconName != null, 'Either icon or iconName must be provided');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.paddingSM.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
          ),
          child: iconName != null 
              ? CustomIcon(name: iconName!, color: AppColors.primary, size: 24.sp)
              : Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: AppSizes.paddingMD.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
