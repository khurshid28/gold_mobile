import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../installment/presentation/pages/contract_page.dart';
import '../../../installment/presentation/pages/installment_selection_page.dart';
import '../../../installment/presentation/widgets/pin_verification_bottom_sheet.dart';
import '../../../profile/presentation/pages/identity_verification_page.dart';
import '../../../profile/presentation/pages/credit_limit_check_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth_state;
import '../../../auth/presentation/bloc/auth_event.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
  }

  void _handleCheckout(BuildContext context, CartLoaded state) {
    // Open installment selection page
    _openInstallmentSelectionPage(context, state);
  }

  Future<void> _openInstallmentSelectionPage(
    BuildContext context,
    CartLoaded state,
  ) async {
    final totalAmount = state.items.fold<double>(
      0,
      (sum, cartItem) => sum + (cartItem.item.finalPrice * cartItem.quantity),
    );

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => InstallmentSelectionPage(
          items: state.items,
          totalAmount: totalAmount,
        ),
      ),
    );

    if (result != null && mounted) {
      final months = result['months'] as int;
      _proceedWithVerificationCheck(context, state, months);
    }
  }

  double _getInterestRate(int months) {
    switch (months) {
      case 3:
        return 0.10;
      case 6:
        return 0.15;
      case 9:
        return 0.20;
      case 12:
        return 0.30;
      default:
        return 0.15;
    }
  }

  void _proceedWithVerificationCheck(
    BuildContext context,
    CartLoaded state,
    int selectedMonths,
  ) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! auth_state.AuthAuthenticated) {
      _showLoginRequiredDialog(context);
      return;
    }

    final user = authState.user;

    // Check if face verified
    if (!user.isVerified) {
      _showFaceVerificationRequiredDialog(context, state, selectedMonths);
      return;
    }

    // Check if has active limit
    final hasActiveLimit =
        user.creditLimit != null &&
        user.limitExpiryDate != null &&
        user.limitExpiryDate!.isAfter(DateTime.now());

    if (!hasActiveLimit) {
      _showLimitRequiredDialog(context, state, selectedMonths);
      return;
    }

    // Check if amount exceeds limit
    if (state.totalPrice > user.creditLimit!) {
      _showInsufficientLimitDialog(context, state.totalPrice);
      return;
    }

    // All checks passed, proceed to contract
    _proceedToContract(context, state, selectedMonths, user.creditLimit!);
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tizimga kirish kerak'),
        content: const Text(
          'Bo\'lib to\'lashdan foydalanish uchun tizimga kirishingiz kerak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: const Text('Kirish'),
          ),
        ],
      ),
    );
  }

  void _showLimitRequiredDialog(
    BuildContext context,
    CartLoaded state,
    int selectedMonths,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(dialogContext);

              // Use widget's context for navigation
              if (!mounted) return;

              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreditLimitCheckPage(),
                ),
              );

              if (!mounted) return;

              if (result != null) {
                context.read<AuthBloc>().add(
                  UpdateUserProfile(
                    creditLimit: result['limit'],
                    limitExpiryDate: result['expiryDate'],
                  ),
                );

                // Small delay to ensure state updates
                await Future.delayed(const Duration(milliseconds: 200));

                if (!mounted) return;

                // Retry checkout
                _proceedWithVerificationCheck(context, state, selectedMonths);
              }
            },
            child: const Text('Limitni tekshirish'),
          ),
        ],
      ),
    );
  }

  void _showFaceVerificationRequiredDialog(
    BuildContext context,
    CartLoaded state,
    int selectedMonths,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'info', color: AppColors.warning),
            SizedBox(width: 12.w),
            Text('Shaxsni tasdiqlang'),
          ],
        ),
        content: Text(
          'Bo\'lib to\'lashdan foydalanish uchun avval hujjat va yuzingizni tasdiqlashingiz kerak.',
          style: TextStyle(
            color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(dialogContext);

              // Use widget's context for navigation
              if (!mounted) return;

              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => const IdentityVerificationPage(),
                ),
              );

              if (!mounted) return;

              if (result != null && result['verified'] == true) {
                context.read<AuthBloc>().add(
                  UpdateUserProfile(
                    isVerified: true,
                    name: result['name'] as String?,
                  ),
                );

                // Check if user clicked continue button
                if (result['action'] == 'continue') {
                  // Continue to limit check
                  final limitResult =
                      await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreditLimitCheckPage(),
                        ),
                      );

                  if (!mounted) return;

                  if (limitResult != null) {
                    context.read<AuthBloc>().add(
                      UpdateUserProfile(
                        creditLimit: limitResult['limit'],
                        limitExpiryDate: limitResult['expiryDate'],
                      ),
                    );
                    // Retry checkout
                    _proceedWithVerificationCheck(
                      context,
                      state,
                      selectedMonths,
                    );
                  }
                }
              }
            },
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  void _proceedToContract(
    BuildContext context,
    CartLoaded state,
    int selectedMonths,
    double creditLimit,
  ) {
    final interestRate = _getInterestRate(selectedMonths);
    final totalAmount = state.totalPrice * (1 + interestRate);
    final monthlyPayment = totalAmount / selectedMonths;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(
          productId: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          productName: 'Savat mahsulotlari (${state.items.length} ta)',
          productImage:
              state.items.isNotEmpty && state.items.first.item.images.isNotEmpty
              ? state.items.first.item.images.first
              : '',
          productPrice: totalAmount,
          selectedMonths: selectedMonths,
          monthlyPayment: monthlyPayment,
          onAgree: () {
            _showPinVerificationBottomSheet(
              context,
              state,
              totalAmount,
              selectedMonths,
              monthlyPayment,
            );
          },
        ),
      ),
    );
  }

  void _showPinVerificationBottomSheet(
    BuildContext context,
    CartLoaded state,
    double totalAmount,
    int selectedMonths,
    double monthlyPayment,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PinVerificationBottomSheet(
        isDark: isDark,
        onVerified: () {
          Navigator.pop(context);
          _showOrderSuccessDialog(
            context,
            isDark,
            totalAmount,
            selectedMonths,
            monthlyPayment,
          );
        },
      ),
    );
  }

  void _showOrderSuccessDialog(
    BuildContext context,
    bool isDark,
    double totalAmount,
    int selectedMonths,
    double monthlyPayment,
  ) {
    // Update usedLimit
    final authState = context.read<AuthBloc>().state;
    if (authState is auth_state.AuthAuthenticated) {
      final currentUsedLimit = authState.user.usedLimit ?? 0.0;
      final newUsedLimit = currentUsedLimit + totalAmount;

      context.read<AuthBloc>().add(UpdateUserProfile(usedLimit: newUsedLimit));
    }

    // Save purchase to SharedPreferences
    _savePurchase(context, totalAmount, selectedMonths, monthlyPayment);

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
                color: isDark
                    ? AppColors.textMediumOnDark
                    : AppColors.textMedium,
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

  Future<void> _savePurchase(
    BuildContext context,
    double totalAmount,
    int selectedMonths,
    double monthlyPayment,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cartState = context.read<CartBloc>().state;

    if (cartState is! CartLoaded) return;

    // Get existing purchases
    final purchasesJson = prefs.getString('purchases') ?? '[]';
    final List<dynamic> purchases = jsonDecode(purchasesJson);

    // Create new purchase
    final now = DateTime.now();
    final nextPayment15th = DateTime(now.year, now.month + 1, 15);

    final newPurchase = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'productName': 'Savat mahsulotlari (${cartState.items.length} ta)',
      'productImage': cartState.items.first.item.images.isNotEmpty
          ? cartState.items.first.item.images.first
          : 'https://via.placeholder.com/150',
      'totalPrice': totalAmount,
      'purchaseDate': DateTime.now().toIso8601String(),
      'status': 'in_progress',
      'isInstallment': true,
      'installmentDetails': {
        'totalAmount': totalAmount,
        'monthlyPayment': monthlyPayment,
        'totalMonths': selectedMonths,
        'paidMonths': 0,
        'remainingAmount': totalAmount,
        'nextPaymentDate': nextPayment15th.toIso8601String(),
      },
    };

    // Add to list
    purchases.insert(0, newPurchase);

    // Save back
    await prefs.setString('purchases', jsonEncode(purchases));
  }

  void _showInsufficientLimitDialog(BuildContext context, double amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.read<AuthBloc>().state;
    double? creditLimit;

    if (authState is auth_state.AuthAuthenticated) {
      creditLimit = authState.user.creditLimit;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'info', color: AppColors.error),
            SizedBox(width: 12.w),
            Text('Limit yetarli emas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (creditLimit != null)
              Text(
                'Sizning limitingiz: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(creditLimit)} so\'m',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                ),
              ),
            SizedBox(height: 8.h),
            Text(
              'Harid summasi: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(amount)} so\'m',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Iltimos, limitingizdan kam bo\'lgan mahsulotlarni tanlang yoki limitingizni oshiring.',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.textMediumOnDark
                    : AppColors.textMedium,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tushunarli'),
          ),
        ],
      ),
    );
  }

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
                message:
                    'Siz hali hech qanday mahsulot qo\'shmadingiz.\nKatalogdan yoqgan mahsulotlaringizni tanlang!',
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
                _CartSummary(
                  state: state,
                  onCheckout: (state) => _handleCheckout(context, state),
                ),
              ],
            );
          }

          return const EmptyStateWidget(
            svgPath: 'assets/images/empty_cart.svg',
            title: 'Savat bo\'sh',
            message:
                'Siz hali hech qanday mahsulot qo\'shmadingiz.\nKatalogdan yoqgan mahsulotlaringizni tanlang!',
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
        content: const Text(
          'Barcha mahsulotlarni savatdan olib tashlamoqchimisiz?',
        ),
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
  final dynamic cartItem;

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
                    child: LoadingWidget(size: 24, color: AppColors.primary),
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
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.textLightOnDark
                          : AppColors.textLight,
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
  final dynamic cartItem;

  const _QuantityControl({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackgroundDark
            : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (cartItem.quantity == 1) {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Mahsulotni o\'chirish'),
                      content: const Text(
                        'Mahsulotni savatdan olib tashlamoqchimisiz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Yo\'q'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<CartBloc>().add(
                              RemoveFromCart(cartItem.item.id),
                            );
                            Navigator.pop(dialogContext);
                          },
                          child: const Text(
                            'Ha',
                            style: TextStyle(color: Colors.red),
                          ),
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
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(AppSizes.radiusSM.r),
              ),
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: CustomIcon(
                  name: 'remove',
                  size: 18,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),

          // Quantity
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: AppColors.gold.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              '${cartItem.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
              ),
            ),
          ),

          // Plus button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<CartBloc>().add(
                  UpdateCartItemQuantity(
                    cartItem.item.id,
                    cartItem.quantity + 1,
                  ),
                );
              },
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(AppSizes.radiusSM.r),
              ),
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: CustomIcon(name: 'add', size: 18, color: AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartLoaded state;
  final Function(CartLoaded) onCheckout;

  const _CartSummary({required this.state, required this.onCheckout});

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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  onCheckout(state);
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
}

// Extension methods removed - moved to class methods
