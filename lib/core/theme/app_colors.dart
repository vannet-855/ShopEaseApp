import 'package:flutter/material.dart';

/// ShopEase design-system color tokens.
/// Primary palette is a deep indigo/violet with warm orange accents,
/// designed to feel premium yet approachable.
abstract class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF5A36E0); // Figma Primary #5A36E0
  static const Color primaryLight = Color(0xFF7E60EE);
  static const Color primaryDark = Color(0xFF4324B8);

  static const Color accent = Color(0xFFFF6B35); // Warm orange / highlight
  static const Color accentLight = Color(0xFFFF8A60);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF21A675);
  static const Color secondary = success;
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFB42318);
  static const Color info = Color(0xFF3B82F6);

  // ─── Neutrals (Light) ─────────────────────────────────────────────────────
  static const Color background = Color(0xFFF6F5FA); // Figma Background #F6F5FA
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFEBFD); // Figma Chip/Light variant #EFEBFD
  static const Color border = Color(0xFFE6E3EF); // Figma Border #E6E3EF

  static const Color textPrimary = Color(0xFF1A1530); // Figma Text #1A1530
  static const Color textSecondary = Color(0xFF5E5A72); // Figma Subtext #5E5A72
  static const Color textHint = Color(0xFF9D98AF);

  // ─── Neutrals (Dark) ──────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0C1D);
  static const Color darkSurface = Color(0xFF1A1530);
  static const Color darkSurfaceVariant = Color(0xFF241E42);
  static const Color darkBorder = Color(0xFF2E2850);

  static const Color darkTextPrimary = Color(0xFFF2EFFF);
  static const Color darkTextSecondary = Color(0xFFADABBF);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5C35E5), Color(0xFF9B59F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0EEF9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
