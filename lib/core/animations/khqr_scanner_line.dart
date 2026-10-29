import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// An animated scanning laser line that glides vertically over the KHQR code.
class KHQRScannerLine extends StatefulWidget {
  final double height;
  final double width;
  final Color beamColor;

  const KHQRScannerLine({
    super.key,
    required this.height,
    required this.width,
    this.beamColor = AppColors.primary,
  });

  @override
  State<KHQRScannerLine> createState() => _KHQRScannerLineState();
}

class _KHQRScannerLineState extends State<KHQRScannerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final yOffset = _controller.value * (widget.height - 4);
            return Stack(
              children: [
                Positioned(
                  top: yOffset,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.beamColor.withValues(alpha: 0.0),
                          widget.beamColor.withValues(alpha: 0.9),
                          widget.beamColor.withValues(alpha: 0.0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.beamColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
