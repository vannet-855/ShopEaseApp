import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/figma_toast.dart';
import '../../core/mock/models/order_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/gradient_button.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('My Orders', style: AppTextStyles.h3),
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const AppIcon(
              AppIcons.chevronLeft,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTextStyles.labelLarge,
            tabs: const [
              Tab(text: 'All Orders'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrdersList(orders: ref.watch(orderProvider)),
            _OrdersList(orders: ref.watch(activeOrdersProvider)),
            _OrdersList(orders: ref.watch(completedOrdersProvider)),
            _OrdersList(orders: ref.watch(cancelledOrdersProvider)),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const AppIcon(
                  AppIcons.packageCheck,
                  size: 52,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),
              Text('No orders here yet', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(
                'Browse products and start shopping!',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 200,
                child: GradientButton(
                  label: 'Start Shopping',
                  onPressed: () => context.go('/home'),
                  height: 48,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => FadeSlideIn(
        delay: Duration(milliseconds: i * 50),
        child: _OrderCard(order: orders[i]),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.processing:
        return AppColors.warning;
      case OrderStatus.shipped:
        return const Color(0xFF3B82F6);
      case OrderStatus.delivered:
        return const Color(0xFF21A675);
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id, style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      '${order.createdAt.month}/${order.createdAt.day}/${order.createdAt.year}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Items thumbnails list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (ctx, idx) {
                  final it = order.items[idx];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: it.product.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.surfaceVariant),
                    ),
                  );
                },
              ),
            ),
          ),

          // Items & Total info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalItemCount} items',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: AppTextStyles.labelLarge
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: BouncingTap(
                    onTap: () {
                      for (final item in order.items) {
                        ref.read(cartProvider.notifier).addItem(item.product);
                      }
                      FigmaToast.show(
                        context,
                        message: 'Items re-added to your cart!',
                        iconAsset: AppIcons.shoppingBag,
                      );
                      context.push('/cart');
                    },
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Reorder',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Track Order',
                    height: 42,
                    onPressed: () => context.push('/order/${order.id}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
