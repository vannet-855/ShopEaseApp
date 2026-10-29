class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> images;
  final String categoryId;
  final String brand;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final bool isActive;
  final List<String> tags;
  final List<String> sizes;
  final List<String> colors;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.images = const [],
    required this.categoryId,
    this.brand = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.tags = const [],
    this.sizes = const [],
    this.colors = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] as String,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      categoryId: json['categoryId'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      rating: (json['rating'] as num? ?? 0).toDouble(),
      reviewCount: json['reviewCount'] as int? ?? 0,
      stock: json['stock'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      sizes: (json['sizes'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'imageUrl': imageUrl,
        'images': images,
        'categoryId': categoryId,
        'brand': brand,
        'rating': rating,
        'reviewCount': reviewCount,
        'stock': stock,
        'isFeatured': isFeatured,
        'isActive': isActive,
        'tags': tags,
        'sizes': sizes,
        'colors': colors,
      };

  /// Backward-compatible getter (category field)
  String get category => categoryId;

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
}

const mockProducts = [
  ProductModel(
    id: 'p1',
    title: 'Nike Air Max 270',
    description:
        'The Nike Air Max 270 delivers an exceptional cushioning experience with its large Air unit.',
    price: 89.99,
    originalPrice: 120.00,
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80',
    categoryId: 'shoes',
    brand: 'Nike',
    rating: 4.7,
    reviewCount: 1243,
    stock: 42,
    isFeatured: true,
  ),
  ProductModel(
    id: 'p2',
    title: 'Sony WH-1000XM5',
    description:
        'Industry-leading noise cancellation meets stunning sound quality.',
    price: 279.99,
    originalPrice: 349.99,
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&q=80',
    categoryId: 'electronics',
    brand: 'Sony',
    rating: 4.9,
    reviewCount: 3021,
    stock: 18,
    isFeatured: true,
  ),
  ProductModel(
    id: 'p3',
    title: 'Apple Watch Series 10',
    description:
        'The thinnest Apple Watch ever, with a larger display and advanced health sensors.',
    price: 399.00,
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&q=80',
    categoryId: 'electronics',
    brand: 'Apple',
    rating: 4.8,
    reviewCount: 876,
    stock: 25,
    isFeatured: true,
  ),
  ProductModel(
    id: 'p4',
    title: 'Minimalist Leather Backpack',
    description:
        'Crafted from full-grain leather with dedicated padded laptop compartment.',
    price: 65.00,
    originalPrice: 95.00,
    imageUrl:
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&q=80',
    categoryId: 'bags',
    brand: 'Nordic Carry',
    rating: 4.6,
    reviewCount: 420,
    stock: 30,
    isFeatured: true,
  ),
  ProductModel(
    id: 'p5',
    title: 'Classic Denim Jacket',
    description:
        'Vintage-wash 100% cotton denim jacket with reinforced seams.',
    price: 79.99,
    originalPrice: 110.00,
    imageUrl:
        'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=400&q=80',
    categoryId: 'clothing',
    brand: 'Urban Thread',
    rating: 4.5,
    reviewCount: 389,
    stock: 15,
    isFeatured: false,
  ),
  ProductModel(
    id: 'p6',
    title: 'Ray-Ban Aviator Classic',
    description:
        'Timeless teardrop shape sunglasses with crystal green lenses and gold frame.',
    price: 154.00,
    imageUrl:
        'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&q=80',
    categoryId: 'accessories',
    brand: 'Ray-Ban',
    rating: 4.7,
    reviewCount: 650,
    stock: 22,
    isFeatured: false,
  ),
];
