import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock/models/order_model.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final wishlistCount = ref.watch(wishlistProvider).length;
    final orders = ref.watch(orderProvider);
    final activeOrders = orders.where((o) =>
        o.status == OrderStatus.processing || o.status == OrderStatus.shipped).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Profile', style: AppTextStyles.h3),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              icon: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: const AppIcon(AppIcons.settings, size: 20, color: AppColors.textPrimary),
              ),
              onPressed: () => context.push('/profile/settings'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── User Info Card ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => context.push('/profile/edit'),
                    child: Container(
                      width: 64, height: 64,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.avatarUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceVariant,
                            alignment: Alignment.center,
                            child: Text(user.initials, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name & email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTextStyles.h3),
                        const SizedBox(height: 3),
                        Text(
                          user.email,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Gold member',
                            style: AppTextStyles.caption.copyWith(
                              color: const Color(0xFFE67E00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit button
                  TextButton(
                    onPressed: () => context.push('/profile/edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Edit',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Menu Items ─────────────────────────────────────────────────
            _ProfileMenuCard(
              items: [
                _ProfileMenuItem(
                  iconAsset: AppIcons.packageCheck,
                  label: 'My Orders',
                  badge: activeOrders > 0 ? '$activeOrders active' : null,
                  iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () => context.push('/orders'),
                ),
                _ProfileMenuItem(
                  iconAsset: AppIcons.location,
                  label: 'Addresses',
                  iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () => context.push('/profile/addresses'),
                ),
                _ProfileMenuItem(
                  iconAsset: AppIcons.heart,
                  label: 'Wishlist',
                  badge: wishlistCount > 0 ? '$wishlistCount items' : null,
                  iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () => context.push('/wishlist'),
                ),
                _ProfileMenuItem(
                  iconAsset: AppIcons.bell,
                  label: 'Notifications',
                  badge: '4 new',
                  iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () => context.push('/notifications'),
                ),
                _ProfileMenuItem(
                  iconAsset: AppIcons.creditCard,
                  label: 'Payment Methods',
                  iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () => context.push('/profile/payments'),
                ),
                _ProfileMenuItem(
                  iconAsset: AppIcons.settings,
                  label: 'Settings',
                  iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () => context.push('/profile/settings'),
                ),
                _ProfileMenuItem(
                  iconAsset: AppIcons.circleHelp,
                  label: 'Help',
                  iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () => context.push('/profile/help'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Logout ─────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => context.go('/login'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Logout',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Menu Card ────────────────────────────────────────────────────────
class _ProfileMenuCard extends StatelessWidget {
  final List<_ProfileMenuItem> items;

  const _ProfileMenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.only(
                    topLeft: i == 0 ? const Radius.circular(16) : Radius.zero,
                    topRight: i == 0 ? const Radius.circular(16) : Radius.zero,
                    bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: item.iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: AppIcon(item.iconAsset, size: 20, color: item.iconColor),
                        ),
                        const SizedBox(width: 14),
                        // Label
                        Expanded(
                          child: Text(item.label, style: AppTextStyles.bodyMedium),
                        ),
                        // Badge
                        if (item.badge != null) ...[
                          Text(
                            item.badge!,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                          ),
                          const SizedBox(width: 6),
                        ],
                        // Chevron
                        const AppIcon(AppIcons.chevronRight, size: 16, color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 70, endIndent: 0),
            ],
          );
        }),
      ),
    );
  }
}

class _ProfileMenuItem {
  final String iconAsset;
  final String label;
  final String? badge;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.iconAsset,
    required this.label,
    this.badge,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });
}
