import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/animated_badge.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _NavItem(iconAsset: AppIcons.house, label: 'Home', path: '/home'),
    _NavItem(iconAsset: AppIcons.grid, label: 'Categories', path: '/categories'),
    _NavItem(iconAsset: AppIcons.shoppingBag, label: 'Cart', path: '/cart'),
    _NavItem(iconAsset: AppIcons.heart, label: 'Wishlist', path: '/wishlist'),
    _NavItem(iconAsset: AppIcons.user, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).uri.toString();
    if (loc.startsWith('/categories') || loc.startsWith('/search')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/wishlist')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final wishlistCount = ref.watch(wishlistProvider).length;
    final current = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = i == current;
                final isCart = tab.path == '/cart';
                final isWishlist = tab.path == '/wishlist';

                return Expanded(
                  child: BouncingTap(
                    onTap: () => context.go(tab.path),
                    scaleFactor: 0.90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.surfaceVariant
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AnimatedScale(
                                scale: isActive ? 1.08 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: AppIcon(
                                  tab.iconAsset,
                                  size: 22,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (isCart && cartCount > 0)
                              Positioned(
                                top: -2,
                                right: 0,
                                child: AnimatedBadge(
                                  count: cartCount,
                                  backgroundColor: AppColors.accent,
                                ),
                              ),
                            if (isWishlist && wishlistCount > 0)
                              Positioned(
                                top: -2,
                                right: 2,
                                child: AnimatedBadge(
                                  count: wishlistCount,
                                  backgroundColor: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isActive ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11,
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String iconAsset;
  final String label;
  final String path;

  const _NavItem({
    required this.iconAsset,
    required this.label,
    required this.path,
  });
}
