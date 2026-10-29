import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/animations/bouncing_tap.dart';
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

/// Pixel-perfect Onboarding Screen matching Figma nodes `Onboarding 1, 2, 3 [6:5224, 6:5247, 6:5270]`.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
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

  void _onUserInteract() {
    _autoTimer?.cancel();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    _onUserInteract();
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Skip Row at Top Right (Figma spec) ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SizedBox(
                height: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < _slides.length - 1)
                      BouncingTap(
                        onTap: _skip,
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5E5A72),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 36),
                  ],
                ),
              ),
            ),

            // ─── Hero Illustration & Content (PageView) ──────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                },
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Column(
                    children: [
                      // Hero Illustration container
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F5FA),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: slide.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFF6F5FA),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Message (Title & Description)
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide.title,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1530),
                                  height: 1.25,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                slide.description,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF5E5A72),
                                  height: 1.45,
                                ),
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

            // ─── Progress & Action (Figma Spec) ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator dots
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        width: isActive ? 28 : 8,
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

                  const SizedBox(height: 24),

                  // Button ("Next" or "Get Started")
                  GradientButton(
                    label: _currentPage == _slides.length - 1
                        ? 'Get Started'
                        : 'Next',
                    iconAsset: _currentPage == _slides.length - 1
                        ? AppIcons.arrowRight
                        : null,
                    onPressed: _next,
                    height: 52,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
