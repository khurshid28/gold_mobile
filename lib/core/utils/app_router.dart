import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:go_router/go_router.dart';
import 'package:gold_mobile/core/widgets/main_layout.dart';
import 'package:gold_mobile/core/widgets/page_not_found_widget.dart';
import 'package:gold_mobile/features/auth/presentation/pages/otp_verify_page.dart';
import 'package:gold_mobile/features/auth/presentation/pages/phone_login_page.dart';
import 'package:gold_mobile/features/auth/presentation/pages/security_settings_page.dart';
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
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/add_card_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/card_otp_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/payments_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/receipt_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/topup_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/transaction_history_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/transfer_page.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/wallet_page.dart';

class AppRouter {
  /// Current top-level location, kept in sync via [router.routerDelegate].
  static final ValueNotifier<String> currentLocation = ValueNotifier('/');

  static final router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const PageNotFoundWidget(),
    redirect: (context, state) {
      currentLocation.value = state.matchedLocation;
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
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
        path: '/security',
        builder: (context, state) =>
            const SecuritySettingsPage(postLogin: true),
      ),
      GoRoute(
        path: '/profile/security',
        builder: (context, state) => const SecuritySettingsPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final initial = int.tryParse(tab ?? '') ?? 0;
          return MainLayout(initialIndex: initial);
        },
      ),
      GoRoute(path: '/stores', builder: (context, state) => const StoresPage()),
      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
      GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesPage()),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      GoRoute(
          path: '/my-purchases',
          builder: (context, state) => const MyPurchasesPage()),
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
          builder: (context, state) => const ProfilePage()),

      // ----- Wallet -----
      GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletPage()),
      GoRoute(
          path: '/wallet/history',
          builder: (context, state) {
            final cardId = state.extra as String?;
            return TransactionHistoryPage(initialCardId: cardId);
          }),
      GoRoute(
          path: '/wallet/add-card',
          builder: (context, state) => const AddCardPage()),
      GoRoute(
        path: '/wallet/add-card/otp',
        builder: (context, state) {
          final payload = state.extra as Map<String, dynamic>;
          return AddCardOtpPage(payload: payload);
        },
      ),
      GoRoute(
        path: '/wallet/transfer',
        builder: (context, state) {
          final card = state.extra as BankCard;
          return TransferPage(from: card);
        },
      ),
      GoRoute(
        path: '/wallet/topup',
        builder: (context, state) {
          final card = state.extra as BankCard;
          return TopUpPage(card: card);
        },
      ),
      GoRoute(
        path: '/wallet/payments',
        builder: (context, state) {
          final card = state.extra as BankCard;
          return PaymentsPage(card: card);
        },
      ),
      GoRoute(
        path: '/wallet/receipt',
        builder: (context, state) {
          final tx = state.extra as WalletTransaction;
          return ReceiptPage(tx: tx);
        },
      ),
    ],
  );
}
