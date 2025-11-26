import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../home/domain/entities/jewelry_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../installment/presentation/pages/contract_page.dart';
import '../../../installment/presentation/widgets/pin_verification_bottom_sheet.dart';
import '../../../installment/presentation/pages/installment_selection_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth_state;
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../profile/presentation/pages/identity_verification_page.dart';
import '../../../profile/presentation/pages/credit_limit_check_page.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';

class ProductDetailPage extends StatefulWidget {
  final JewelryItem item;

  const ProductDetailPage({super.key, required this.item});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

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
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardBackgroundDark
                      : Colors.white.withOpacity(0.9),
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
              BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  final isFavorite =
                      state is FavoritesLoaded &&
                      state.isFavorite(widget.item.id);

                  return IconButton(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(
                        ToggleFavorite(widget.item.id),
                      );
                    },
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFavorite ? Colors.red : AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${widget.item.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.item.images.isNotEmpty
                      ? widget.item.images[0]
                      : '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: LoadingWidget(size: 50, color: AppColors.primary),
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
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
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
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
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
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSM.r,
                                ),
                              ),
                              child: Text(
                                widget.item.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
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
                          value: widget.item.inStock
                              ? 'Omborda bor'
                              : 'Tugagan',
                          valueColor: widget.item.inStock
                              ? Colors.green
                              : Colors.red,
                        ),
                        SizedBox(height: AppSizes.paddingXXL.h),

                        // Description
                        Text(
                          'Tavsif',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: AppSizes.paddingMD.h),
                        Text(
                          widget.item.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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
                                        _showInstallmentConfirmDialog(
                                          context,
                                          isDark,
                                        );
                                      }
                                    : null,
                                icon: const CustomIcon(
                                  name: 'check_circle',
                                  size: 20,
                                ),
                                label: const Text('Bo\'lib to\'lash'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSizes.paddingMD.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMD.r,
                                    ),
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Savatga qo\'shildi'),
                                            duration: Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'Ko\'rish',
                                              onPressed: () {
                                                // Navigate back to home and switch to cart tab
                                                Navigator.of(context).popUntil(
                                                  (route) => route.isFirst,
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.shopping_cart_rounded),
                                label: const Text('Savatga'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSizes.paddingMD.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMD.r,
                                    ),
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

  void _showInstallmentConfirmDialog(BuildContext context, bool isDark) {
    // Check auth status
    final authState = context.read<AuthBloc>().state;

    if (authState is! auth_state.AuthAuthenticated) {
      _showAuthRequiredDialog(context);
      return;
    }

    final user = authState.user;

    // Check face verification
    if (!user.isVerified) {
      _showFaceVerificationRequiredDialog(context, isDark);
      return;
    }

    // Check credit limit
    if (user.creditLimit == null || user.limitExpiryDate == null) {
      _showLimitRequiredDialog(context, isDark);
      return;
    }

    // Check if limit expired
    if (user.limitExpiryDate!.isBefore(DateTime.now())) {
      _showLimitExpiredDialog(context);
      return;
    }

    // Open installment selection
    _openInstallmentSelectionPage(context);
  }

  Future<void> _openInstallmentSelectionPage(BuildContext context) async {
    // Create a CartItem from the current product
    final cartItem = CartItem(item: widget.item, quantity: 1);

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => InstallmentSelectionPage(
          items: [cartItem],
          totalAmount: widget.item.finalPrice,
        ),
      ),
    );

    if (result != null && mounted) {
      final selectedMonths = result['months'] as int;
      final authState = context.read<AuthBloc>().state;

      if (authState is auth_state.AuthAuthenticated) {
        final availableLimit = authState.user.availableLimit;
        _proceedToContract(context, selectedMonths, availableLimit);
      }
    }
  }

  void _proceedToContract(
    BuildContext context,
    int selectedMonths,
    double availableLimit,
  ) {
    final interestRate = _getInterestRate(selectedMonths);
    final totalAmount = widget.item.finalPrice * (1 + interestRate);
    final monthlyPayment = totalAmount / selectedMonths;

    // Check if available limit is sufficient
    if (totalAmount > availableLimit) {
      _showInsufficientLimitDialog(context, totalAmount, availableLimit);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractPage(
          productId: widget.item.id,
          productName: widget.item.name,
          productImage: widget.item.images.isNotEmpty
              ? widget.item.images.first
              : '',
          productPrice: totalAmount,
          selectedMonths: selectedMonths,
          monthlyPayment: monthlyPayment,
          onAgree: () {
            _showPinVerificationBottomSheet(
              context,
              totalAmount,
              selectedMonths,
              monthlyPayment,
            );
          },
        ),
      ),
    );
  }

  double _getInterestRate(int months) {
    switch (months) {
      case 3:
        return 0.05; // 5%
      case 6:
        return 0.10; // 10%
      case 9:
        return 0.15; // 15%
      case 12:
        return 0.20; // 20%
      case 18:
        return 0.30; // 30%
      case 24:
        return 0.40; // 40%
      default:
        return 0.20;
    }
  }

  void _showAuthRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'info', color: AppColors.error),
            SizedBox(width: 12.w),
            Text('Ro\'yxatdan o\'ting'),
          ],
        ),
        content: Text('Bo\'lib to\'lash uchun tizimga kirishingiz kerak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/phone-login');
            },
            child: Text('Kirish'),
          ),
        ],
      ),
    );
  }

  void _showFaceVerificationRequiredDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'face_id', color: AppColors.info),
            SizedBox(width: 12.w),
            Text('Shaxsni tasdiqlash'),
          ],
        ),
        content: Text(
          'Bo\'lib to\'lash uchun shaxsingizni tasdiqlashingiz kerak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (!mounted) return;

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IdentityVerificationPage(),
                ),
              );

              if (result != null && mounted) {
                context.read<AuthBloc>().add(
                  UpdateUserProfile(isVerified: true),
                );
              }
            },
            child: Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  void _showLimitRequiredDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CustomIcon(name: 'wallet', color: AppColors.gold),
            SizedBox(width: 12.w),
            Text('Limit kerak'),
          ],
        ),
        content: Text(
          'Bo\'lib to\'lash uchun kredit limitini tekshirishingiz kerak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (!mounted) return;

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreditLimitCheckPage(),
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
            child: Text('Limitni tekshirish'),
          ),
        ],
      ),
    );
  }

  void _showLimitExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 12.w),
            Text('Limit muddati tugagan'),
          ],
        ),
        content: Text(
          'Kredit limitingiz muddati tugagan. Iltimos, yangidan tekshiring.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientLimitDialog(
    BuildContext context,
    double amount,
    double availableLimit,
  ) {
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
            Text(
              'Sizning mavjud limitingiz: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(availableLimit)} so\'m',
            ),
            SizedBox(height: 8.h),
            Text(
              'Kerakli summa: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(amount)} so\'m',
            ),
            SizedBox(height: 12.h),
            Text(
              'Iltimos, boshqa mahsulotni tanlang yoki savatdagi mahsulotlar sonini kamaytiring.',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPinVerificationBottomSheet(
    BuildContext context,
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

    // Show success dialog
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
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 50.sp,
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
              widget.item.name,
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
                Navigator.pop(context); // Close product detail page
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
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing purchases
      final purchasesJson = prefs.getString('purchases') ?? '[]';
      final List<dynamic> purchases = jsonDecode(purchasesJson);

      // Calculate next payment date (15th of next month)
      final now = DateTime.now();
      final nextPaymentDate = DateTime(now.year, now.month + 1, 15);

      // Create new purchase
      final newPurchase = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'productName': widget.item.name,
        'productImage': widget.item.images.isNotEmpty
            ? widget.item.images.first
            : '',
        'purchaseDate': now.toIso8601String(),
        'totalPrice': totalAmount,
        'status': 'in_progress',
        'isInstallment': true,
        'installmentDetails': {
          'totalAmount': totalAmount,
          'monthlyPayment': monthlyPayment,
          'totalMonths': selectedMonths,
          'paidMonths': 0,
          'remainingAmount': totalAmount,
          'nextPaymentDate': nextPaymentDate.toIso8601String(),
        },
      };

      // Add to beginning of list
      purchases.insert(0, newPurchase);

      // Save back to SharedPreferences
      await prefs.setString('purchases', jsonEncode(purchases));
    } catch (e) {
      debugPrint('Error saving purchase: $e');
    }
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
  }) : assert(
         icon != null || iconName != null,
         'Either icon or iconName must be provided',
       );

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
              ? CustomIcon(
                  name: iconName!,
                  color: AppColors.primary,
                  size: 24.sp,
                )
              : Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: AppSizes.paddingMD.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
