import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock/models/category_model.dart';
import '../mock/models/product_model.dart';
import '../mock/models/review_model.dart';
import '../services/api_service.dart';

// ── API-backed providers ──────────────────────────────────────────────────────

/// All products fetched from JSON data source.
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final json = await ApiService.instance.getProducts();
  return json
      .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
      .where((p) => p.isActive)
      .toList();
});

/// All categories fetched from JSON data source.
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final json = await ApiService.instance.getCategories();
  return json
      .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Featured products (isFeatured == true).
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final all = await ref.watch(productsProvider.future);
  return all.where((p) => p.isFeatured).toList();
});

/// Reviews for a specific product.
final reviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, productId) async {
  final json = await ApiService.instance.getReviewsByProduct(productId);
  return json
      .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ── Wishlist (local state) ────────────────────────────────────────────────────

class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'p1', 'p2', 'p3', 'p4', 'p5', 'p6'};

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = Set<String>.from(state)..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  bool isWishlisted(String productId) => state.contains(productId);
}

final wishlistProvider = NotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

/// Products in the wishlist (derived from wishlistProvider + productsProvider).
final wishlistProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final ids = ref.watch(wishlistProvider);
  if (ids.isEmpty) return [];
  final all = await ref.watch(productsProvider.future);
  return all.where((p) => ids.contains(p.id)).toList();
});

// ── Category filter (local UI state) ─────────────────────────────────────────

final selectedCategoryProvider = NotifierProvider<_SelectedCatNotifier, String>(
  _SelectedCatNotifier.new,
);

class _SelectedCatNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void select(String cat) => state = cat;
}

/// Products filtered by selected category.
final filteredProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  final cat = ref.watch(selectedCategoryProvider);
  if (cat == 'all') return products;
  return products
      .where((p) => p.categoryId.toLowerCase() == cat.toLowerCase())
      .toList();
});

/// Search query state notifier.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

/// Search query state.
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Products matching the search query.
final searchResultsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return products;
  return products.where((p) {
    return p.title.toLowerCase().contains(query) ||
        p.brand.toLowerCase().contains(query) ||
        p.categoryId.toLowerCase().contains(query) ||
        p.tags.any((t) => t.toLowerCase().contains(query));
  }).toList();
});
