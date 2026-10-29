import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_icon.dart';

/// A bouncing elastic heart button for adding/removing items to wishlist.
class PulseHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;

  const PulseHeartButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
  });

  @override
  State<PulseHeartButton> createState() => _PulseHeartButtonState();
}

class _PulseHeartButtonState extends State<PulseHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 0.90)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.90, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final activeCol = widget.activeColor ?? AppColors.error;
    final inactiveCol = widget.inactiveColor ?? AppColors.textSecondary;

    Widget iconWidget = ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: AppIcon(
          AppIcons.heart,
          key: ValueKey<bool>(widget.isFavorite),
          size: widget.size,
          color: widget.isFavorite ? activeCol : inactiveCol,
        ),
      ),
    );

    if (widget.backgroundColor != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: iconWidget,
        ),
      );
    }

    return IconButton(
      icon: iconWidget,
      onPressed: _handleTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
