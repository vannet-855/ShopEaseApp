import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/mock/models/cart_item_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/gradient_button.dart';

/// Pixel-perfect Shopping Cart screen matching Figma node `Shopping cart [6:5683]`.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoCtrl.text.trim();
    if (code.isNotEmpty) {
      ref.read(promoCodeProvider.notifier).apply(code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code "$code" applied! 15% discount'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final totalItems = ref.watch(cartItemCountProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(promoDiscountProvider);
    final appliedPromo = ref.watch(promoCodeProvider);

    final shipping = subtotal > 50 || subtotal == 0 ? 0.0 : 4.99;
    final total = (subtotal - discount + shipping).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: items.isEmpty
            ? _EmptyCart(onBrowse: () => context.go('/home'))
            : Column(
                children: [
                  // ─── Top Bar (Figma spec: Back, "My Cart", Clear) ───────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BouncingTap(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const AppIcon(
                                AppIcons.chevronLeft,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            'My Cart',
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          BouncingTap(
                            onTap: () =>
                                ref.read(cartProvider.notifier).clear(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const AppIcon(
                                AppIcons.trash,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Cart Items & Order Totals ──────────────────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Subtitle: "4 items in your bag"
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            '$totalItems items in your bag',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Item list
                        ...List.generate(items.length, (i) {
                          return FadeSlideIn(
                            delay: Duration(milliseconds: i * 40),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CartItemCard(item: items[i]),
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        // ─── Promo Code Box (Figma Spec) ─────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: appliedPromo != null
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const AppIcon(
                                AppIcons.ticketPercent,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _promoCtrl,
                                  decoration: InputDecoration(
                                    hintText: appliedPromo != null
                                        ? 'Promo: $appliedPromo applied'
                                        : 'Enter promo code',
                                    hintStyle:
                                        AppTextStyles.bodyMedium.copyWith(
                                      color: appliedPromo != null
                                          ? AppColors.primary
                                          : AppColors.textHint,
                                      fontWeight: appliedPromo != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              BouncingTap(
                                onTap: appliedPromo != null
                                    ? () {
                                        ref
                                            .read(promoCodeProvider.notifier)
                                            .remove();
                                        _promoCtrl.clear();
                                      }
                                    : _applyPromo,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    appliedPromo != null ? 'Remove' : 'Apply',
                                    style: TextStyle(
                                      color: appliedPromo != null
                                          ? AppColors.error
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ─── Order Totals Card (Figma Spec) ──────────────────
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _SummaryLine(
                                label: 'Subtotal',
                                value: '\$${subtotal.toStringAsFixed(2)}',
                              ),
                              if (discount > 0) ...[
                                const SizedBox(height: 8),
                                _SummaryLine(
                                  label: 'Promo Discount (15%)',
                                  value: '-\$${discount.toStringAsFixed(2)}',
                                  valueColor: AppColors.success,
                                ),
                              ],
                              const SizedBox(height: 8),
                              _SummaryLine(
                                label: 'Shipping',
                                value: shipping == 0.0
                                    ? 'Free'
                                    : '\$${shipping.toStringAsFixed(2)}',
                                valueColor: shipping == 0.0
                                    ? const Color(0xFF1E7A4F)
                                    : AppColors.textPrimary,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  color: Color(0xFFE6E3EF),
                                  height: 1,
                                ),
                              ),
                              _SummaryLine(
                                label: 'Total',
                                value: '\$${total.toStringAsFixed(2)}',
                                isBold: true,
                                valueColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ─── Checkout Action Button (Figma Spec) ─────────────
                        GradientButton(
                          label: 'Checkout • \$${total.toStringAsFixed(2)}',
                          onPressed: () => context.push('/checkout'),
                          height: 52,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Cart Item Card matching Figma ───────────────────────────────────────────
class _CartItemCard extends ConsumerWidget {
  final CartItemModel item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 78,
              height: 78,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.title,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    BouncingTap(
                      onTap: () => cart.removeItem(item.product.id),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.product.brand} • ${item.product.colors.isNotEmpty ? item.product.colors[0] : 'Standard'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),

                    // Quantity Stepper (Figma: - [Value] +)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F5FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuantityButton(
                            iconAsset: AppIcons.minus,
                            onTap: () => cart.updateQuantity(
                                item.product.id, item.quantity - 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            iconAsset: AppIcons.plus,
                            onTap: () => cart.updateQuantity(
                                item.product.id, item.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback onTap;

  const _QuantityButton({required this.iconAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.88,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: AppIcon(iconAsset, size: 12, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ??
                (isBold ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ─── Empty Cart matching Wishlist button ──────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppIcon(
                AppIcons.shoppingBag,
                size: 54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text('Your cart is empty', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Start shopping and add items to your cart',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: GradientButton(
                label: 'Browse Products',
                onPressed: onBrowse,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
