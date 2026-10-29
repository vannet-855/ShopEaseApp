import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';

/// Category model representing each category card from the Figma design.
class CategoryCardData {
  final String id;
  final String name;
  final String itemCount;
  final String imageUrl;

  const CategoryCardData({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.imageUrl,
  });
}

/// Pixel-perfect Categories screen matching Figma node `Categories screen [6:5441]`.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const List<CategoryCardData> _categories = [
    CategoryCardData(
      id: 'fashion',
      name: 'Fashion',
      itemCount: '1,284 items',
      imageUrl:
          'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&auto=format&fit=crop&q=80',
    ),
    CategoryCardData(
      id: 'electronics',
      name: 'Electronics',
      itemCount: '846 items',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
    ),
    CategoryCardData(
      id: 'home',
      name: 'Home & Living',
      itemCount: '932 items',
      imageUrl:
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600&auto=format&fit=crop&q=80',
    ),
    CategoryCardData(
      id: 'beauty',
      name: 'Beauty',
      itemCount: '618 items',
      imageUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&auto=format&fit=crop&q=80',
    ),
    CategoryCardData(
      id: 'sports',
      name: 'Sports',
      itemCount: '504 items',
      imageUrl:
          'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=600&auto=format&fit=crop&q=80',
    ),
    CategoryCardData(
      id: 'accessories',
      name: 'Accessories',
      itemCount: '721 items',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80',
    ),
    CategoryCardData(
      id: 'kids',
      name: 'Kids',
      itemCount: '389 items',
      imageUrl:
          'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=600&auto=format&fit=crop&q=80',
    ),
    CategoryCardData(
      id: 'gifts',
      name: 'Gifts',
      itemCount: '268 items',
      imageUrl:
          'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Top Bar (Figma spec: 402x52) ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Balances right action button to center title perfectly
                    const SizedBox(width: 36, height: 36),
                    Text(
                      'Categories',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    BouncingTap(
                      onTap: () => context.push('/search'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const AppIcon(
                          AppIcons.search,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Categories Grid (Figma spec: 2 cols, 173x155, r: 20) ──────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 173 / 155,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return FadeSlideIn(
                    delay: Duration(milliseconds: 40 * index),
                    child: _CategoryCard(
                      category: cat,
                      onTap: () {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .select(cat.id);
                        context.push('/search?category=${cat.id}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryCardData category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.96,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: category.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                alignment: Alignment.center,
                child: const AppIcon(
                  AppIcons.shoppingBag,
                  size: 28,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Linear Gradient overlay (transparent -> dark tint at bottom)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF17121D).withValues(alpha: 0.72),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),

            // Top-right Arrow Button (Figma: 30x30 white circle, arrow-up-right)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  AppIcons.arrowUpRight,
                  size: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Bottom-left Category details (Name & Item count)
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.itemCount,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.2,
                    ),
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
