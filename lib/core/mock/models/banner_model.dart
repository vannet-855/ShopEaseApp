class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? discount;
  final String ctaLabel;
  final String deepLink;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.discount,
    this.ctaLabel = 'Shop Now',
    this.deepLink = '/search',
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      discount: json['discount'] as String?,
      ctaLabel: json['ctaLabel'] as String? ?? 'Shop Now',
      deepLink: json['deepLink'] as String? ?? '/search',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'discount': discount,
        'ctaLabel': ctaLabel,
        'deepLink': deepLink,
      };
}
