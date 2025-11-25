import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../installment/presentation/pages/contract_page.dart';
import '../../../installment/presentation/widgets/pin_verification_bottom_sheet.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savat'),
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return IconButton(
                  icon: const CustomIcon(name: 'delete', size: 24),
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const EmptyStateWidget(
                svgPath: 'assets/images/empty_cart.svg',
                title: 'Savat bo\'sh',
                message: 'Siz hali hech qanday mahsulot qo\'shmadingiz.\nKatalogdan yoqgan mahsulotlaringizni tanlang!',
                actionText: 'Katalogga o\'tish',
              );
            }
            
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppSizes.paddingLG),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = state.items[index];
                      return _CartItemCard(cartItem: cartItem);
                    },
                  ),
                ),
                _CartSummary(state: state),
              ],
            );
          }
          
          return const EmptyStateWidget(
            svgPath: 'assets/images/empty_cart.svg',
            title: 'Savat bo\'sh',
            message: 'Siz hali hech qanday mahsulot qo\'shmadingiz.\nKatalogdan yoqgan mahsulotlaringizni tanlang!',
            actionText: 'Katalogga o\'tish',
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Savatni tozalash'),
        content: const Text('Barcha mahsulotlarni savatdan olib tashlamoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(ClearCart());
              Navigator.pop(dialogContext);
            },
            child: const Text('Tozalash', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final cartItem;

  const _CartItemCard({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final item = cartItem.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMD.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
              child: CachedNetworkImage(
                imageUrl: item.images.isNotEmpty ? item.images[0] : '',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.grey.withOpacity(0.1),
                  child: const Center(
                    child: LoadingWidget(
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.grey.withOpacity(0.1),
                  child: const Icon(Icons.image_not_supported_rounded),
                ),
              ),
            ),
            SizedBox(width: AppSizes.paddingMD.w),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.textLightOnDark : AppColors.textLight,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(item.finalPrice)} so\'m',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _QuantityControl(cartItem: cartItem),
                    ],
                  ),
                ],
              ),
            ),
            
            // Remove button
            IconButton(
              icon: const CustomIcon(name: 'close', size: 20),
              onPressed: () {
                context.read<CartBloc>().add(RemoveFromCart(item.id));
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final cartItem;

  const _QuantityControl({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (cartItem.quantity == 1) {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Mahsulotni o\'chirish'),
                    content: const Text('Mahsulotni savatdan olib tashlamoqchimisiz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Yo\'q'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<CartBloc>().add(RemoveFromCart(cartItem.item.id));
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Ha', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                context.read<CartBloc>().add(
                      UpdateCartItemQuantity(
                        cartItem.item.id,
                        cartItem.quantity - 1,
                      ),
                    );
              }
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: CustomIcon(name: 'close', size: 16, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '${cartItem.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              context.read<CartBloc>().add(
                    UpdateCartItemQuantity(
                      cartItem.item.id,
                      cartItem.quantity + 1,
                    ),
                  );
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: CustomIcon(name: 'check', size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartLoaded state;

  const _CartSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jami mahsulotlar:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${state.totalItems} ta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.paddingSM.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jami summa:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(state.totalPrice)} so\'m',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.paddingMD.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showCheckoutConfirmation(context, state);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMD.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
                  ),
                ),
                child: const Text('Rasmiylashtirish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutConfirmation(BuildContext context, CartLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const selectedMonths = 12;
    final monthlyPayment = state.totalPrice / selectedMonths;

    // Get first item name for display
    final firstItemName = state.items.isNotEmpty ? state.items.first.item.name : 'Mahsulotlar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'shopping_cart', color: AppColors.gold),
            SizedBox(width: 12.w),
            Text('Rasmiylashtirish'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mahsulotlar soni: ${state.items.length} ta'),
            SizedBox(height: 8.h),
            Text('Umumiy summa: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(state.totalPrice)} so\'m'),
            SizedBox(height: 8.h),
            Text('Muddat: $selectedMonths oy'),
            SizedBox(height: 8.h),
            Text(
              'Oylik to\'lov: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(monthlyPayment)} so\'m',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
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
              _showContractPage(context, firstItemName, state.totalPrice, selectedMonths, monthlyPayment, isDark);
            },
            child: const Text('Davom etish'),
          ),
        ],
      ),
    );
  }

  void _showContractPage(BuildContext context, String productName, double totalPrice, int selectedMonths, double monthlyPayment, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(
          productName: productName,
          productPrice: totalPrice,
          selectedMonths: selectedMonths,
          monthlyPayment: monthlyPayment,
          onAgree: () {
            _showPinVerificationBottomSheet(context, isDark);
          },
        ),
      ),
    );
  }

  void _showPinVerificationBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PinVerificationBottomSheet(
        isDark: isDark,
        onVerified: () {
          Navigator.pop(context);
          _showSuccessDialog(context, isDark);
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, bool isDark) {
    // Clear cart after successful order
    context.read<CartBloc>().add(ClearCart());
    
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
              'Savat mahsulotlari',
              textAlign: TextAlign.center,
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

