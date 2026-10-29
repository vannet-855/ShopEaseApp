import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/animations/page_transitions.dart';
import '../core/mock/models/order_model.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/categories/categories_screen.dart';
import '../features/search/search_screen.dart';
import '../features/product/product_detail_screen.dart';
import '../features/product/product_reviews_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/payment_methods_screen.dart';
import '../features/profile/shipping_addresses_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/profile/help_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/checkout/khqr_payment_screen.dart';
import '../features/checkout/order_success_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/notifications/notifications_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ─── Onboarding / Auth ─────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (ctx, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (ctx, state) => buildPageWithFadeThroughTransition(
        context: ctx,
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const RegisterScreen(),
      ),
    ),

    // ─── Product Detail ────────────────────────────────────────────────────
    GoRoute(
      path: '/product/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: ProductDetailScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
    ),

    // ─── Product Reviews ───────────────────────────────────────────────────
    GoRoute(
      path: '/product/:id/reviews',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: ProductReviewsScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
    ),

    // ─── Notifications ─────────────────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const NotificationsScreen(),
      ),
    ),

    // ─── Checkout Flow ─────────────────────────────────────────────────────
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: '/checkout/khqr',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) {
        final order = state.extra as OrderModel;
        return buildPageWithFadeThroughTransition(
          context: ctx,
          state: state,
          child: KHQRPaymentScreen(order: order),
        );
      },
    ),
    GoRoute(
      path: '/checkout/success',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) {
        final order = state.extra as OrderModel?;
        return buildPageWithFadeThroughTransition(
          context: ctx,
          state: state,
          child: OrderSuccessScreen(order: order),
        );
      },
    ),

    // ─── Orders Flow ───────────────────────────────────────────────────────
    GoRoute(
      path: '/orders',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const OrdersScreen(),
      ),
    ),
    GoRoute(
      path: '/order/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
    ),

    // ─── Profile Sub-screens ───────────────────────────────────────────────
    GoRoute(
      path: '/profile/edit',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/payments',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const PaymentMethodsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/addresses',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const ShippingAddressesScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/settings',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/help',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (ctx, state) => buildPageWithSlideTransition(
        context: ctx,
        state: state,
        child: const HelpScreen(),
      ),
    ),

    // ─── Main Shell (bottom nav tabs) ──────────────────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (ctx, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (ctx, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/categories',
          builder: (ctx, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (ctx, state) => SearchScreen(
            initialCategory: state.uri.queryParameters['category'],
          ),
        ),
        GoRoute(
          path: '/cart',
          builder: (ctx, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/wishlist',
          builder: (ctx, state) => const WishlistScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (ctx, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
