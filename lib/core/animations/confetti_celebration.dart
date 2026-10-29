import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A celebratory confetti burst simulation for order placement and checkout success.
class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool autoStart;

  const ConfettiCelebration({
    super.key,
    required this.child,
    this.autoStart = true,
  });

  @override
  State<ConfettiCelebration> createState() => ConfettiCelebrationState();
}

class ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _initParticles();

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  void _initParticles() {
    _particles.clear();
    const colors = [
      AppColors.primary,
      Color(0xFF21A675),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF38BDF8),
    ];

    for (int i = 0; i < 48; i++) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final speed = 120.0 + _rnd.nextDouble() * 260.0;
      final color = colors[_rnd.nextInt(colors.length)];
      final size = 5.0 + _rnd.nextDouble() * 7.0;
      final rotationSpeed = (_rnd.nextDouble() - 0.5) * 8.0;
      final isCircle = _rnd.nextBool();

      _particles.add(
        _ConfettiParticle(
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 160.0,
          color: color,
          size: size,
          rotationSpeed: rotationSpeed,
          isCircle: isCircle,
        ),
      );
    }
  }

  void play() {
    _initParticles();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (!_controller.isAnimating && _controller.isCompleted) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotationSpeed;
  final bool isCircle;

  _ConfettiParticle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.22);
    final gravity = 480.0 * progress * progress;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final x = center.dx + p.vx * progress;
      final y = center.dy + p.vy * progress + gravity;
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed * pi);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// An animated glowing pulse ring surrounding the success checkmark.
class GlowingPulseRing extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;

  const GlowingPulseRing({
    super.key,
    required this.child,
    this.color = const Color(0xFF21A675),
    this.size = 110,
  });

  @override
  State<GlowingPulseRing> createState() => _GlowingPulseRingState();
}

class _GlowingPulseRingState extends State<GlowingPulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.4,
      height: widget.size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: _opacityAnimation.value),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
