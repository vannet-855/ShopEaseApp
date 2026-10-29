import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final Color textColor;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.textColor = Colors.white,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final hex = json['colorHex'] as String? ?? 'CCCCCC';
    final color = Color(int.parse('FF$hex', radix: 16));
    // Determine text color (dark for light backgrounds)
    final luminance = color.computeLuminance();
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      color: color,
      textColor: luminance > 0.5 ? const Color(0xFF1A1235) : Colors.white,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorHex': color.toARGB32().toRadixString(16).substring(2).toUpperCase(),
      };
}
