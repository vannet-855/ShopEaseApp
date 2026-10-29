import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/order_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final order = orders.where((o) => o.id == orderId).firstOrNull;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 60, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text('Order not found', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Orders'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order ${order.id}', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(
            AppIcons.chevronLeft,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const AppIcon(AppIcons.delivery,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ${order.statusLabel}',
                            style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated: ${order.estimatedDelivery.month}/${order.estimatedDelivery.day}/${order.estimatedDelivery.year}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tracking Timeline
            Text('Tracking History', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(order.trackingSteps.length, (idx) {
                  final step = order.trackingSteps[idx];
                  final isLast = idx == order.trackingSteps.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: step.isCompleted
                                  ? AppColors.secondary
                                  : (step.isCurrent
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: step.isCompleted || step.isCurrent
                                    ? Colors.transparent
                                    : AppColors.border,
                              ),
                            ),
                            child: Icon(
                              step.isCompleted
                                  ? Icons.check
                                  : (step.isCurrent
                                      ? Icons.circle
                                      : Icons.circle_outlined),
                              size: step.isCompleted ? 14 : 10,
                              color: step.isCompleted || step.isCurrent
                                  ? Colors.white
                                  : AppColors.textHint,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 48,
                              color: step.isCompleted
                                  ? AppColors.secondary
                                  : AppColors.border,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    step.title,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: step.isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: step.isCompleted || step.isCurrent
                                          ? AppColors.textPrimary
                                          : AppColors.textHint,
                                    ),
                                  ),
                                  Text(
                                    step.time,
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.textHint),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.description,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Items Purchased
            Text('Items in Order', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(order.items.length, (idx) {
                  final it = order.items[idx];
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: idx == order.items.length - 1 ? 0 : 14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: it.product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: AppColors.surfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.product.title,
                                  style: AppTextStyles.labelLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${it.quantity} • \$${it.product.price.toStringAsFixed(2)} each',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${it.totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.labelLarge
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Details & Payment Method
            Text('Shipping & Payment', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.deliveryAddress.name,
                                style: AppTextStyles.labelLarge),
                            const SizedBox(height: 2),
                            Text(
                              order.deliveryAddress.fullAddress,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.credit_card_outlined,
                          color: AppColors.secondary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.paymentMethod.title,
                                style: AppTextStyles.labelLarge),
                            const SizedBox(height: 2),
                            Text(
                              order.paymentMethod.maskedNumber,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _SummaryItem('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _SummaryItem(
                    'Shipping',
                    order.shippingFee == 0.0
                        ? 'FREE'
                        : '\$${order.shippingFee.toStringAsFixed(2)}',
                  ),
                  if (order.discount > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryItem('Discount', '-\$${order.discount.toStringAsFixed(2)}',
                        isDiscount: true),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Paid', style: AppTextStyles.h4),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: AppTextStyles.priceLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support CTA
            OutlinedButton.icon(
              onPressed: () => context.push('/profile/help'),
              icon: const Icon(Icons.help_outline_rounded, size: 18),
              label: const Text('Need Help With This Order?'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _SummaryItem(this.label, this.value, {this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: isDiscount ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
