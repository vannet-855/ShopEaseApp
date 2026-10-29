import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/animations/confetti_celebration.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/mock/models/order_model.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/gradient_button.dart';

/// Screen matching Figma node 6:5824 ("Order confirmation").
class OrderSuccessScreen extends ConsumerWidget {
  final OrderModel? order;
  const OrderSuccessScreen({super.key, this.order});

  String _formatDeliveryDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final m = months[dt.month - 1];
    return '$m ${dt.day}-${dt.day + 2}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userName = user.name.split(' ').first;
    final orderId = order?.id ?? 'SE-240938';
    final deliveryText = order != null
        ? _formatDeliveryDate(order!.estimatedDelivery)
        : 'October 6-8';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
        body: ConfettiCelebration(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Success Treatment matching Figma Outer Glow + Checkmark
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: GlowingPulseRing(
                      color: const Color(0xFF21A675),
                      size: 96,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFF21A675),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF21A675).withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: AppIcon(
                            AppIcons.check,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Success Title & Copy matching Figma 6:5824
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        Text(
                          'Order confirmed!',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 26,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thanks, $userName. Your order is on its way to being packed with care.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Order Details Card matching Figma
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Number Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order number',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '#$orderId',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: AppColors.border, height: 1),
                          ),

                          // Delivery Estimate with package-check icon
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: AppIcon(
                                    AppIcons.packageCheck,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated delivery',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    deliveryText,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Progress Tracker (Confirmed -> Shipped -> Delivered)
                          _FigmaProgressTracker(currentStep: 1),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions matching Figma: Track Order & Continue Shopping
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        GradientButton(
                          label: 'Track Order',
                          iconAsset: AppIcons.location,
                          onPressed: () => context.go('/orders'),
                        ),
                        const SizedBox(height: 12),
                        BouncingTap(
                          onTap: () => context.go('/home'),
                          child: OutlinedButton(
                            onPressed: () => context.go('/home'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: AppColors.border, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: AppColors.surface,
                            ),
                            child: Text(
                              'Continue Shopping',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FigmaProgressTracker extends StatelessWidget {
  final int currentStep; // 1 = Confirmed, 2 = Shipped, 3 = Delivered

  const _FigmaProgressTracker({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildStepDot(1, isActive: currentStep >= 1),
            Expanded(child: _buildLine(isActive: currentStep >= 2)),
            _buildStepDot(2, isActive: currentStep >= 2),
            Expanded(child: _buildLine(isActive: currentStep >= 3)),
            _buildStepDot(3, isActive: currentStep >= 3),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 70,
              child: Text(
                'Confirmed',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: currentStep >= 1 ? FontWeight.w700 : FontWeight.normal,
                  color: currentStep >= 1 ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                'Shipped',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: currentStep >= 2 ? FontWeight.w700 : FontWeight.normal,
                  color: currentStep >= 2 ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                'Delivered',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: currentStep >= 3 ? FontWeight.w700 : FontWeight.normal,
                  color: currentStep >= 3 ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepDot(int step, {required bool isActive}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isActive
            ? const Icon(Icons.check, size: 13, color: Colors.white)
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }

  Widget _buildLine({required bool isActive}) {
    return Container(
      height: 3,
      color: isActive ? AppColors.primary : AppColors.border,
    );
  }
}
