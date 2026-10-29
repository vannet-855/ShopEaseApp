import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized Figma Icon registry for ShopEase.
/// Every icon is a pixel-perfect vector directly extracted from the Figma UI.
class AppIcons {
  AppIcons._();

  static const String basePath = 'assets/icons';

  static const String house = '$basePath/house.svg';
  static const String grid = '$basePath/grid_2x2.svg';
  static const String shoppingBag = '$basePath/shopping_bag.svg';
  static const String heart = '$basePath/heart.svg';
  static const String user = '$basePath/user.svg';
  static const String search = '$basePath/search.svg';
  static const String slidersHorizontal = '$basePath/sliders_horizontal.svg';
  static const String filter = '$basePath/filter.svg';
  static const String bell = '$basePath/bell.svg';
  static const String star = '$basePath/star.svg';
  static const String chevronLeft = '$basePath/chevron_left.svg';
  static const String chevronRight = '$basePath/chevron_right.svg';
  static const String chevronDown = '$basePath/chevron_down.svg';
  static const String arrowRight = '$basePath/arrow_right.svg';
  static const String arrowUpRight = '$basePath/arrow_up_right.svg';
  static const String plus = '$basePath/plus.svg';
  static const String minus = '$basePath/minus.svg';
  static const String check = '$basePath/check.svg';
  static const String checkCircle = '$basePath/check_circle.svg';
  static const String trash = '$basePath/trash.svg';
  static const String lock = '$basePath/lock.svg';
  static const String eyeOff = '$basePath/eye_off.svg';
  static const String location = '$basePath/location.svg';
  static const String delivery = '$basePath/delivery.svg';
  static const String packageCheck = '$basePath/package_check.svg';
  static const String shieldCheck = '$basePath/shield_check.svg';
  static const String google = '$basePath/google.svg';
  static const String apple = '$basePath/apple.svg';
  static const String qrCode = '$basePath/qr_code.svg';
  static const String creditCard = '$basePath/credit_card.svg';
  static const String khqrScan = '$basePath/khqr_scan.svg';
  static const String settings = '$basePath/settings.svg';
  static const String circleHelp = '$basePath/circle_help.svg';
  static const String ticketPercent = '$basePath/ticket_percent.svg';
}

/// Convenience widget to render Figma SVG icons with optional tint color and size.
class AppIcon extends StatelessWidget {
  final String assetName;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;

  const AppIcon(
    this.assetName, {
    super.key,
    this.size = 20,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width ?? size,
      height: height ?? size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
