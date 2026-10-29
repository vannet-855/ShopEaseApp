import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock/models/payment_method_model.dart';
import '../../core/providers/address_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/gradient_button.dart';

// ─── Payment Option data class ────────────────────────────────────────────────
enum _FigmaPayment { cashOnDelivery, khqr, bankTransfer }

class _PaymentOption {
  final _FigmaPayment type;
  final String title;
  final String subtitle;

  const _PaymentOption({required this.type, required this.title, required this.subtitle});
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isSubmitting = false;

  static const _paymentOptions = [
    _PaymentOption(
      type: _FigmaPayment.cashOnDelivery,
      title: 'Cash on Delivery',
      subtitle: 'Pay when your order arrives',
    ),
    _PaymentOption(
      type: _FigmaPayment.khqr,
      title: 'KHQR',
      subtitle: 'Scan securely with any Cambodian bank',
    ),
    _PaymentOption(
      type: _FigmaPayment.bankTransfer,
      title: 'Bank Transfer',
      subtitle: 'Transfer from your banking app',
    ),
  ];

  _FigmaPayment _selectedPayment = _FigmaPayment.khqr;

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openAddressPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final addresses = ref.watch(addressProvider);
          final selectedId = ref.watch(selectedAddressIdProvider);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Delivery Address', style: AppTextStyles.h3),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add New'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/profile/addresses');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...addresses.map((addr) {
                  final isSelected = addr.id == selectedId;
                  return InkWell(
                    onTap: () {
                      ref.read(selectedAddressIdProvider.notifier).select(addr.id);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppColors.primary : AppColors.textHint,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(addr.name, style: AppTextStyles.labelLarge),
                                const SizedBox(height: 4),
                                Text(
                                  addr.fullAddress,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onPlaceOrder() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) {
      _showSnack('Your cart is empty', isError: true);
      return;
    }
    final address = ref.read(activeShippingAddressProvider);
    if (address == null) {
      _showSnack('Please select a shipping address', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final PaymentMethodModel paymentModel;
    if (_selectedPayment == _FigmaPayment.khqr) {
      paymentModel = const PaymentMethodModel(
        id: 'pay_khqr', type: PaymentType.khqr,
        title: 'KHQR', last4: 'KHQR',
        cardHolder: 'ShopEase', expiry: '--/--',
      );
    } else if (_selectedPayment == _FigmaPayment.cashOnDelivery) {
      paymentModel = const PaymentMethodModel(
        id: 'pay_cod', type: PaymentType.cashOnDelivery,
        title: 'Cash on Delivery', last4: 'COD',
        cardHolder: '', expiry: '--/--',
      );
    } else {
      paymentModel = const PaymentMethodModel(
        id: 'pay_bank', type: PaymentType.visa,
        title: 'Bank Transfer', last4: '0000',
        cardHolder: '', expiry: '--/--',
      );
    }

    final order = ref.read(orderProvider.notifier).createOrder(
      items: cartItems,
      deliveryAddress: address,
      paymentMethod: paymentModel,
      shippingFee: 0.0,
      discount: 0.0,
    );

    setState(() => _isSubmitting = false);

    if (_selectedPayment == _FigmaPayment.khqr) {
      context.push('/checkout/khqr', extra: order);
    } else {
      context.go('/checkout/success', extra: order);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final address = ref.watch(activeShippingAddressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        centerTitle: true,
        title: Text('Checkout', style: AppTextStyles.h3),
        leading: IconButton(
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const AppIcon(AppIcons.chevronLeft, size: 18, color: AppColors.textPrimary),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const AppIcon(AppIcons.shieldCheck, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(AppIcons.shoppingBag, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No items to checkout', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Explore Products'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Shipping Address ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shipping address', style: AppTextStyles.h4),
                      TextButton(
                        onPressed: _openAddressPicker,
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
                  const SizedBox(height: 10),
                  _AddressCard(
                    name: address?.name ?? 'Add Address',
                    addressLine: address?.fullAddress ?? 'Tap to select a delivery address',
                    onTap: _openAddressPicker,
                  ),

                  const SizedBox(height: 24),

                  // ── Payment Method ────────────────────────────────────────
                  Text('Payment method', style: AppTextStyles.h4),
                  const SizedBox(height: 10),
                  ..._paymentOptions.map((option) {
                    final isSelected = _selectedPayment == option.type;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PaymentCard(
                        option: option,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedPayment = option.type),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // ── Order Summary ─────────────────────────────────────────
                  _OrderSummaryCard(cartItems: cartItems, subtotal: subtotal),
                ],
              ),
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              color: AppColors.surface,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GradientButton(
                      label: _isSubmitting
                          ? 'Processing...'
                          : 'Place Order · \$${subtotal.toStringAsFixed(2)}',
                      iconAsset: _isSubmitting ? null : AppIcons.lock,
                      loading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _onPlaceOrder,
                      height: 56,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          'Secure encrypted payment',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Address Card ─────────────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final String name;
  final String addressLine;
  final VoidCallback onTap;

  const _AddressCard({required this.name, required this.addressLine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const AppIcon(AppIcons.location, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 3),
                    Text(
                      addressLine,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Payment Card ─────────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final _PaymentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentCard({required this.option, required this.isSelected, required this.onTap});

  Widget _buildIcon() {
    switch (option.type) {
      case _FigmaPayment.khqr:
        return const AppIcon(AppIcons.khqrScan, color: AppColors.primary, size: 22);
      case _FigmaPayment.cashOnDelivery:
        return const Icon(Icons.payments_outlined, color: AppColors.primary, size: 22);
      case _FigmaPayment.bankTransfer:
        return const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 22);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _buildIcon(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.title, style: AppTextStyles.labelLarge),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Container(
                          key: const ValueKey('checked'),
                          width: 24, height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                        )
                      : Container(
                          key: const ValueKey('unchecked'),
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Order Summary Card ───────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final List<dynamic> cartItems;
  final double subtotal;

  const _OrderSummaryCard({required this.cartItems, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final itemCount = cartItems.fold<int>(0, (sum, item) => sum + (item.quantity as int));
    final now = DateTime.now();
    final start = now.add(const Duration(days: 3));
    final end = now.add(const Duration(days: 5));
    final months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final deliveryLabel = 'Standard delivery · ${months[start.month]} ${start.day}–${end.day}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order summary', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deliveryLabel,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'Free',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.h4),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: AppTextStyles.priceLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
