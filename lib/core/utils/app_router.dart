import 'package:go_router/go_router.dart';
import 'package:gold_mobile/core/widgets/main_layout.dart';
import 'package:gold_mobile/core/widgets/page_not_found_widget.dart';
import 'package:gold_mobile/features/auth/presentation/pages/otp_verify_page.dart';
import 'package:gold_mobile/features/auth/presentation/pages/phone_login_page.dart';
import 'package:gold_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:gold_mobile/features/stores/presentation/pages/stores_page.dart';
import 'package:gold_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:gold_mobile/features/favorites/presentation/pages/favorites_page.dart';
import 'package:gold_mobile/features/search/presentation/pages/search_page.dart';
import 'package:gold_mobile/features/my_purchases/presentation/pages/my_purchases_page.dart';
import 'package:gold_mobile/features/installment/presentation/pages/installment_page.dart';
import 'package:gold_mobile/features/product/presentation/pages/product_detail_page.dart';
import 'package:gold_mobile/features/home/presentation/pages/category_page.dart';
import 'package:gold_mobile/features/home/domain/entities/jewelry_item.dart';
import 'package:gold_mobile/features/home/domain/entities/category.dart';
import 'package:gold_mobile/features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const PageNotFoundWidget(),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final phoneNumber = state.extra as String;
          return OtpVerifyPage(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/stores',
        builder: (context, state) => const StoresPage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/my-purchases',
        builder: (context, state) => const MyPurchasesPage(),
      ),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final item = state.extra as JewelryItem;
          return ProductDetailPage(item: item);
        },
      ),
      GoRoute(
        path: '/installment',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return InstallmentPage(
            productId: params['productId'] as String,
            productName: params['productName'] as String,
            productImage: params['productImage'] as String,
            productPrice: params['productPrice'] as double,
          );
        },
      ),
      GoRoute(
        path: '/category',
        builder: (context, state) {
          final category = state.extra as Category;
          return CategoryPage(category: category);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
