import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/gradient_button.dart';

class _OnboardingItem {
  final String title;
  final String description;
  final String imageUrl;

  const _OnboardingItem({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

const List<_OnboardingItem> _slides = [
  _OnboardingItem(
    title: 'Browse thousands of products',
    description:
        'Discover curated fashion, tech, beauty, and home essentials—all in one place.',
    imageUrl:
        'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=800&auto=format&fit=crop&q=80',
  ),
  _OnboardingItem(
    title: 'Fast checkout in seconds',
    description:
        'Save your details, choose a payment method, and place your order without the wait.',
    imageUrl:
        'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=800&auto=format&fit=crop&q=80',
  ),
  _OnboardingItem(
    title: 'Track your delivery live',
    description:
        'Follow every step from checkout to your doorstep with clear real-time updates.',
    imageUrl:
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800&auto=format&fit=crop&q=80',
  ),
];

/// Pixel-perfect Onboarding Screen matching Figma nodes `Onboarding 1, 2, 3`.
/// Layout: full-bleed hero image (PageView), floating Skip pill at top-right,
/// and a rounded-top-corner white content card at the bottom with animated
/// title/description, dot indicators, and a Next / Get Started button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _contentFade =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _contentCtrl.forward();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(milliseconds: 3800), (_) {
      if (!mounted) return;
      if (_currentPage < _slides.length - 1) {
        _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _autoTimer?.cancel();
      }
    });
  }

  void _onUserInteract() => _autoTimer?.cancel();

  void _animateContent() {
    _contentCtrl.reset();
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _next() {
    _onUserInteract();
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    _onUserInteract();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final safeTop = MediaQuery.paddingOf(context).top;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-bleed hero image PageView ────────────────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                _animateContent();
              },
              itemCount: _slides.length,
              itemBuilder: (ctx, i) =>
                  _HeroImage(imageUrl: _slides[i].imageUrl),
            ),
          ),

          // ── Top gradient scrim ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Skip pill button ──────────────────────────────────────────────
          Positioned(
            top: safeTop + 12,
            right: 20,
            child: AnimatedOpacity(
              opacity: _currentPage < _slides.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: _currentPage >= _slides.length - 1,
                child: BouncingTap(
                  onTap: _skip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1530),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom white content card ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(maxHeight: size.height * 0.44),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 32,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(28, 30, 28, safeBottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Animated title + description ──────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1530),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide.description,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF5E5A72),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Dots left, Button right ───────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Page indicator dots
                      Row(
                        children: List.generate(_slides.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 6),
                            width: isActive ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF5A36E0)
                                  : const Color(0xFFE6E3EF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const Spacer(),

                      // Next / Get Started button
                      SizedBox(
                        width: 148,
                        child: GradientButton(
                          label: _currentPage == _slides.length - 1
                              ? 'Get Started'
                              : 'Next',
                          iconAsset: _currentPage == _slides.length - 1
                              ? AppIcons.arrowRight
                              : null,
                          onPressed: _next,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Image ───────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String imageUrl;
  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (context, url) => Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
      ),
    );
  }
}
