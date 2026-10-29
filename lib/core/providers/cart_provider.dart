import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock/models/cart_item_model.dart';
import '../mock/models/product_model.dart';

const List<CartItemModel> _defaultCartItems = [
  CartItemModel(
    product: ProductModel(
      id: 'p1',
      title: 'Nike Air Max 270',
      description:
          'The Nike Air Max 270 delivers an exceptional cushioning experience with its large Air unit.',
      price: 89.99,
      originalPrice: 120.00,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80',
      images: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
      ],
      categoryId: 'shoes',
      brand: 'Nike',
      rating: 4.7,
      reviewCount: 1243,
      stock: 42,
      isFeatured: true,
      isActive: true,
      tags: ['trending', 'sport'],
      sizes: ['7', '8', '9', '10', '11'],
      colors: ['Black', 'White', 'Red'],
    ),
    quantity: 1,
  ),
  CartItemModel(
    product: ProductModel(
      id: 'p2',
      title: 'Sony WH-1000XM5',
      description:
          'Industry-leading noise cancellation meets stunning sound quality. Up to 30-hour battery life.',
      price: 279.99,
      originalPrice: 349.99,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&q=80',
      images: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
      ],
      categoryId: 'electronics',
      brand: 'Sony',
      rating: 4.9,
      reviewCount: 3021,
      stock: 18,
      isFeatured: true,
      isActive: true,
      tags: ['bestseller', 'tech'],
      sizes: [],
      colors: ['Black', 'Silver'],
    ),
    quantity: 1,
  ),
  CartItemModel(
    product: ProductModel(
      id: 'p4',
      title: "Levi's 501 Original Jeans",
      description:
          'The blueprint for every pair of jeans in existence with a timeless straight fit.',
      price: 59.99,
      originalPrice: 79.99,
      imageUrl:
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400&q=80',
      images: [
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&q=80',
      ],
      categoryId: 'fashion',
      brand: "Levi's",
      rating: 4.5,
      reviewCount: 4512,
      stock: 65,
      isFeatured: false,
      isActive: true,
      tags: ['denim', 'classic'],
      sizes: ['30', '32', '34', '36'],
      colors: ['Blue', 'Black'],
    ),
    quantity: 2,
  ),
];

/// Cart state notifier with automated initial items.
class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() => List<CartItemModel>.from(_defaultCartItems);

  void addItem(ProductModel product) {
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      final updated = List<CartItemModel>.from(state);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItemModel(product: product, quantity: 1)];
    }
  }

  void removeItem(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final updated = List<CartItemModel>.from(state);
    final idx = updated.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      updated[idx] = updated[idx].copyWith(quantity: qty);
      state = updated;
    }
  }

  void clear() => state = [];

  void resetToDefault() => state = List<CartItemModel>.from(_defaultCartItems);

  double get subtotal => state.fold(0, (sum, i) => sum + i.totalPrice);
  int get totalItems => state.fold(0, (sum, i) => sum + i.quantity);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(
  CartNotifier.new,
);

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, i) => sum + i.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, i) => sum + i.totalPrice);
});

class PromoCodeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void apply(String code) => state = code.trim().toUpperCase();
  void remove() => state = null;
}

final promoCodeProvider = NotifierProvider<PromoCodeNotifier, String?>(
  PromoCodeNotifier.new,
);

final promoDiscountProvider = Provider<double>((ref) {
  final promo = ref.watch(promoCodeProvider);
  final subtotal = ref.watch(cartSubtotalProvider);
  if (promo == null || promo.isEmpty) return 0.0;
  return subtotal * 0.15; // 15% discount for valid promo
});
