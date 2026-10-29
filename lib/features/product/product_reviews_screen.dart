import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/mock/models/review_model.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProductReviewsScreen extends ConsumerWidget {
  final String productId;

  const ProductReviewsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Customer Reviews', style: AppTextStyles.h3),
      ),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Failed to load reviews')),
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_border_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text('No reviews yet', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to review this product',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          // Summary stats
          final avgRating = reviews.fold<double>(
                  0, (sum, r) => sum + r.rating) /
              reviews.length;
          final Map<int, int> ratingDist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
          for (final r in reviews) {
            ratingDist[(r.rating.round()).clamp(1, 5)] =
                (ratingDist[(r.rating.round()).clamp(1, 5)] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // ── Rating Summary Card ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // Big avg rating
                    Column(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        _StarRow(rating: avgRating, size: 18),
                        const SizedBox(height: 4),
                        Text(
                          '${reviews.length} reviews',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Distribution bars
                    Expanded(
                      child: Column(
                        children: [5, 4, 3, 2, 1].map((stars) {
                          final count = ratingDist[stars] ?? 0;
                          final pct =
                              reviews.isEmpty ? 0.0 : count / reviews.length;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text('$stars',
                                    style: AppTextStyles.labelSmall),
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded,
                                    size: 12, color: AppColors.warning),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 6,
                                      backgroundColor:
                                          AppColors.surfaceVariant,
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              AppColors.warning),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 24,
                                  child: Text('$count',
                                      style: AppTextStyles.labelSmall
                                          .copyWith(
                                              color:
                                                  AppColors.textSecondary)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text('All Reviews (${reviews.length})',
                  style: AppTextStyles.h4),
              const SizedBox(height: 12),

              // ── Review cards ────────────────────────────────────────────
              ...reviews.map((r) => _ReviewCard(review: r)),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: review.userAvatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      review.userName.isNotEmpty
                          ? review.userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 2),
                    _StarRow(rating: review.rating, size: 14),
                  ],
                ),
              ),
              Text(
                _timeAgo(review.createdAt),
                style:
                    AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: AppTextStyles.bodyMedium),
          if (review.helpful > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.thumb_up_outlined,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  '${review.helpful} found this helpful',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: AppColors.warning,
        );
      }),
    );
  }
}
