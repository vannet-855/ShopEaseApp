import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mock/models/product_model.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/product_card.dart';

enum SortOption {
  relevant,
  priceLowHigh,
  priceHighLow,
  topRated,
}

class SearchFilterState {
  final String query;
  final String? category;
  final RangeValues priceRange;
  final double minRating;
  final SortOption sortOption;

  const SearchFilterState({
    this.query = '',
    this.category,
    this.priceRange = const RangeValues(0, 1500),
    this.minRating = 0.0,
    this.sortOption = SortOption.relevant,
  });

  SearchFilterState copyWith({
    String? query,
    String? Function()? category,
    RangeValues? priceRange,
    double? minRating,
    SortOption? sortOption,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get hasActiveFilters =>
      category != null ||
      priceRange.start > 0 ||
      priceRange.end < 1500 ||
      minRating > 0;
}

class _SearchFilterNotifier extends Notifier<SearchFilterState> {
  @override
  SearchFilterState build() => const SearchFilterState();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(String? c) => state = state.copyWith(category: () => c);
  void setPriceRange(RangeValues r) => state = state.copyWith(priceRange: r);
  void setMinRating(double r) => state = state.copyWith(minRating: r);
  void setSortOption(SortOption s) => state = state.copyWith(sortOption: s);
  void resetFilters() =>
      state = state.copyWith(category: () => null, priceRange: const RangeValues(0, 1500), minRating: 0.0);
}

final _searchFilterProvider =
    NotifierProvider<_SearchFilterNotifier, SearchFilterState>(
  _SearchFilterNotifier.new,
);

final _searchResultsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final filter = ref.watch(_searchFilterProvider);
  final query = filter.query.toLowerCase().trim();
  var list = await ref.watch(productsProvider.future);

  // Filter by query
  if (query.isNotEmpty) {
    list = list
        .where((p) =>
            p.title.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query) ||
            p.categoryId.toLowerCase().contains(query) ||
            p.tags.any((t) => t.toLowerCase().contains(query)))
        .toList();
  }

  // Filter by category
  if (filter.category != null) {
    list = list.where((p) => p.categoryId == filter.category).toList();
  }

  // Filter by price range
  list = list
      .where((p) =>
          p.price >= filter.priceRange.start && p.price <= filter.priceRange.end)
      .toList();

  // Filter by rating
  if (filter.minRating > 0) {
    list = list.where((p) => p.rating >= filter.minRating).toList();
  }

  // Sort
  switch (filter.sortOption) {
    case SortOption.priceLowHigh:
      list.sort((a, b) => a.price.compareTo(b.price));
      break;
    case SortOption.priceHighLow:
      list.sort((a, b) => b.price.compareTo(a.price));
      break;
    case SortOption.topRated:
      list.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case SortOption.relevant:
      break;
  }

  return list;
});

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const SearchScreen({super.key, this.initialCategory});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();

  final List<String> _popularTags = const [
    'Headphones',
    'Smart Watch',
    'Sneakers',
    'Backpack',
    'Sunglasses',
    'Hoodie',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(_searchFilterProvider.notifier)
            .setCategory(widget.initialCategory);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final filter = ref.read(_searchFilterProvider);
    final categoriesAsync = ref.read(categoriesProvider);
    final categories = categoriesAsync.value ?? [];

    RangeValues currentRange = filter.priceRange;
    String? currentCategory = filter.category;
    double currentRating = filter.minRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
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
                    Text('Filter Products', style: AppTextStyles.h3),
                    TextButton(
                      onPressed: () {
                        ref.read(_searchFilterProvider.notifier).resetFilters();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category chips
                Text('Category', style: AppTextStyles.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: currentCategory == null,
                      onSelected: (val) {
                        if (val) setSheetState(() => currentCategory = null);
                      },
                    ),
                    ...categories.map((c) {
                      final sel = currentCategory == c.id;
                      return ChoiceChip(
                        label: Text(c.name),
                        selected: sel,
                        onSelected: (val) {
                          setSheetState(() => currentCategory = val ? c.id : null);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Price range slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Price Range', style: AppTextStyles.labelLarge),
                    Text(
                      '\$${currentRange.start.round()} - \$${currentRange.end.round()}',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                RangeSlider(
                  values: currentRange,
                  min: 0,
                  max: 1500,
                  divisions: 30,
                  activeColor: AppColors.primary,
                  onChanged: (vals) {
                    setSheetState(() => currentRange = vals);
                  },
                ),
                const SizedBox(height: 20),

                // Rating filter
                Text('Minimum Rating', style: AppTextStyles.labelLarge),
                const SizedBox(height: 10),
                Row(
                  children: [0.0, 4.0, 4.5].map((r) {
                    final sel = currentRating == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (r > 0) ...[
                              const AppIcon(
                                AppIcons.star,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(r == 0.0 ? 'Any' : '$r+ Stars'),
                          ],
                        ),
                        selected: sel,
                        onSelected: (val) {
                          if (val) setSheetState(() => currentRating = r);
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      ref
                          .read(_searchFilterProvider.notifier)
                          .setCategory(currentCategory);
                      ref
                          .read(_searchFilterProvider.notifier)
                          .setPriceRange(currentRange);
                      ref
                          .read(_searchFilterProvider.notifier)
                          .setMinRating(currentRating);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(_searchResultsProvider);
    final results = resultsAsync.value ?? [];
    final filter = ref.watch(_searchFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: TextField(
          controller: _ctrl,
          onChanged: (v) =>
              ref.read(_searchFilterProvider.notifier).setQuery(v),
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search products, tags, brands...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textHint),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: AppIcon(
                AppIcons.search,
                color: AppColors.textHint,
                size: 18,
              ),
            ),
            suffixIcon: ValueListenableBuilder(
              valueListenable: _ctrl,
              builder: (ctx, val, _) => val.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 20, color: AppColors.textHint),
                      onPressed: () {
                        _ctrl.clear();
                        ref
                            .read(_searchFilterProvider.notifier)
                            .setQuery('');
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        actions: [
          // Filter Button with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const AppIcon(
                  AppIcons.slidersHorizontal,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: _openFilterSheet,
              ),
              if (filter.hasActiveFilters)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // Sort Menu
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.swap_vert_rounded),
            onSelected: (opt) =>
                ref.read(_searchFilterProvider.notifier).setSortOption(opt),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: SortOption.relevant,
                child: Text('Relevance'),
              ),
              const PopupMenuItem(
                value: SortOption.priceLowHigh,
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: SortOption.priceHighLow,
                child: Text('Price: High to Low'),
              ),
              const PopupMenuItem(
                value: SortOption.topRated,
                child: Text('Top Rated'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // If query is empty and no filters, show popular searches row
          if (_ctrl.text.isEmpty && !filter.hasActiveFilters) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Popular Searches', style: AppTextStyles.h4),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _popularTags.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final tag = _popularTags[i];
                  return ActionChip(
                    label: Text(tag),
                    backgroundColor: AppColors.surface,
                    onPressed: () {
                      _ctrl.text = tag;
                      ref
                          .read(_searchFilterProvider.notifier)
                          .setQuery(tag);
                    },
                  );
                },
              ),
            ),
          ],

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${results.length} products found',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (filter.hasActiveFilters)
                  GestureDetector(
                    onTap: () =>
                        ref.read(_searchFilterProvider.notifier).resetFilters(),
                    child: Text(
                      'Clear filters',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),

          // Grid Results
          Expanded(
            child: resultsAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text('No products match your criteria',
                            style: AppTextStyles.h4),
                        const SizedBox(height: 6),
                        Text(
                          'Try adjusting your search terms or filters',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: results.length,
                    itemBuilder: (ctx, i) =>
                        ProductCard(product: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
