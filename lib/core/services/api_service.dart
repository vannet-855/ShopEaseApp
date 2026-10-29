import 'dart:convert';
import 'package:flutter/services.dart';

/// Simulates a REST API by loading data from local JSON asset files.
/// In production, replace the `_load` calls with actual HTTP requests.
class ApiService {
  ApiService._();
  static final instance = ApiService._();

  // ── Base path (swap to http://10.0.2.2:3000 for a real json-server) ───────
  static const _assetsBase = 'assets/data';

  Future<dynamic> _load(String file) async {
    final raw = await rootBundle.loadString('$_assetsBase/$file');
    return jsonDecode(raw);
  }

  // ── Products ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate network
    return await _load('products.json') as List<dynamic>;
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    final list = await getProducts();
    try {
      return list.firstWhere((p) => p['id'] == id) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  Future<List<dynamic>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return await _load('categories.json') as List<dynamic>;
  }

  // ── Banners ────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = await _load('banners.json') as List<dynamic>;
    return list.where((b) => b['isActive'] == true).toList()
      ..sort((a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int));
  }

  // ── Reviews ────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getReviewsByProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = await _load('reviews.json') as List<dynamic>;
    return list.where((r) => r['productId'] == productId).toList();
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  Future<List<dynamic>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = await _load('notifications.json') as List<dynamic>;
    list.sort((a, b) =>
        DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
    return list;
  }
}
