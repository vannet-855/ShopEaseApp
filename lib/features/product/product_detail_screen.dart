import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/animations/figma_toast.dart';
import '../../core/animations/pulse_heart_button.dart';
import '../../core/animations/shimmer_loading.dart';
import '../../core/mock/models/product_model.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/gradient_button.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _imageIndex = 0;
  int _quantity = 1;
  bool _adding = false;

  ProductModel? _findProduct(List<ProductModel> products) {
    try {
      return products.firstWhere((p) => p.id == widget.productId);
    } catch (_) {
      return null;
    }
  }

  void _addToCart(ProductModel product) async {
    setState(() => _adding = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      for (int i = 0; i < _quantity; i++) {
        ref.read(cartProvider.notifier).addItem(product);
      }
      setState(() => _adding = false);
      if (mounted) {
        FigmaToast.show(
          context,
          message: '${product.title} added to cart!',
          iconAsset: AppIcons.shoppingBag,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Failed to load product')),
      ),
      data: (products) {
        final product = _findProduct(products);
        final isWishlisted = product != null
            ? ref
                .watch(wishlistProvider.select((s) => s.contains(product.id)))
            : false;

        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Product not found')),
          );
        }

        final allImages =
            product.images.isNotEmpty ? product.images : [product.imageUrl];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Image ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: IconButton(
                      icon: const AppIcon(
                        AppIcons.chevronLeft,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: PulseHeartButton(
                      isFavorite: isWishlisted,
                      backgroundColor: Colors.white,
                      size: 20,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.textPrimary,
                      onToggle: () => ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: allImages.length,
                        onPageChanged: (i) =>
                            setState(() => _imageIndex = i),
                        itemBuilder: (ctx, i) {
                          final imgWidget = CachedNetworkImage(
                            imageUrl: allImages[i],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const ShimmerBox(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 0,
                            ),
                          );
                          return i == 0
                              ? Hero(
                                  tag: 'product-image-${product.id}',
                                  child: imgWidget,
                                )
                              : imgWidget;
                        },
                      ),
                      // Image indicator dots
                      if (allImages.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              allImages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _imageIndex ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == _imageIndex
                                      ? AppColors.primary
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Product Info ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(product.title, style: AppTextStyles.h2),
                        const SizedBox(height: 10),

                        // Rating row
                        InkWell(
                          onTap: () =>
                              context.push('/product/${product.id}/reviews'),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(right: 2),
                                    child: AppIcon(
                                      AppIcons.star,
                                      size: 16,
                                      color: i < product.rating.floor()
                                          ? AppColors.warning
                                          : AppColors.border,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${product.rating} (${product.reviewCount} reviews)',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const Spacer(),
                                Text(
                                  'See Reviews',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const AppIcon(
                                  AppIcons.chevronRight,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${product.price.toStringAsFixed(2)}',
                                style: AppTextStyles.priceXL),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 10),
                              Text(
                                '\$${product.originalPrice!.toStringAsFixed(2)}',
                                style: AppTextStyles.priceOriginal.copyWith(
                                    fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${product.discountPercent.toStringAsFixed(0)}%',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Quantity selector
                        Row(
                          children: [
                            Text('Quantity', style: AppTextStyles.labelLarge),
                            const Spacer(),
                            _QuantitySelector(
                              quantity: _quantity,
                              onChanged: (q) =>
                                  setState(() => _quantity = q),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Divider(),
                        const SizedBox(height: 16),

                        // Description
                        Text('Description', style: AppTextStyles.h4),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary, height: 1.7),
                        ),
                        const SizedBox(height: 16),

                        // Stock info
                        if (product.stock > 0)
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: product.stock < 10
                                      ? AppColors.warning
                                      : AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.stock < 10
                                    ? 'Only ${product.stock} left in stock!'
                                    : 'In Stock (${product.stock} available)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: product.stock < 10
                                      ? AppColors.warning
                                      : AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom CTA ───────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: GradientButton(
                label: 'Add to Cart — \$${(product.price * _quantity).toStringAsFixed(2)}',
                loading: _adding,
                onPressed: () => _addToCart(product),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QBtn(
            iconAsset: AppIcons.minus,
            onTap: () => quantity > 1 ? onChanged(quantity - 1) : null,
            enabled: quantity > 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelLarge,
            ),
          ),
          _QBtn(
            iconAsset: AppIcons.plus,
            onTap: () => onChanged(quantity + 1),
            enabled: true,
          ),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final String iconAsset;
  final VoidCallback? onTap;
  final bool enabled;
  const _QBtn({required this.iconAsset, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: enabled ? onTap : null,
      scaleFactor: 0.88,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: AppIcon(
          iconAsset,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}
