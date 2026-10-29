import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/figma_toast.dart';
import '../../core/animations/khqr_scanner_line.dart';
import '../../core/mock/models/order_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/gradient_button.dart';

class KHQRPaymentScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const KHQRPaymentScreen({super.key, required this.order});

  @override
  ConsumerState<KHQRPaymentScreen> createState() => _KHQRPaymentScreenState();
}

class _KHQRPaymentScreenState extends ConsumerState<KHQRPaymentScreen> {
  int _secondsRemaining = 292; // ~4:52 from Figma
  Timer? _timer;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer() {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onConfirmPayment() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.go('/checkout/success', extra: widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(
            AppIcons.chevronLeft,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pay with KHQR',
          style: AppTextStyles.h3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          children: [
            // ── Merchant Info ───────────────────────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 60),
              child: Column(
                children: [
                  Text(
                    'Amount due to ShopEase Cambodia',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${widget.order.total.toStringAsFixed(2)}',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${widget.order.id}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── QR Card with Animated Scanner ──────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // KHQR Header Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11927), // KHQR Official Red
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(AppIcons.khqrScan, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'KHQR',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // QR Image Area with Animated Laser Line
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const AppIcon(
                              AppIcons.qrCode,
                              size: 190,
                              color: AppColors.textPrimary,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE11927),
                                shape: BoxShape.circle,
                              ),
                              child: const AppIcon(
                                AppIcons.shoppingBag,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            // Vertical Animated Scanner Beam
                            const KHQRScannerLine(
                              width: 196,
                              height: 196,
                              beamColor: Color(0xFFE11927),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Demo Notice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'DEMO • NOT A REAL PAYMENT CODE',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Actions: Timer + Save QR (with FigmaToast)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Expires in ${_formatTimer()}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        BouncingTap(
                          onTap: () {
                            FigmaToast.show(
                              context,
                              message: 'QR code saved to your Photos',
                              iconAsset: AppIcons.check,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.download_rounded,
                                  size: 16,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Save QR',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Scan Instructions ───────────────────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan with your banking app',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Open any KHQR-enabled Cambodian banking app (ABA, ACLEDA, Bakong, Wing, etc.) and scan. Confirm the merchant and amount before paying.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Trust Note ──────────────────────────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIcon(AppIcons.shieldCheck, size: 16, color: Color(0xFF21A675)),
                  const SizedBox(width: 6),
                  Text(
                    'Protected by National Bank of Cambodia Bakong system',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── CTA: Payment Completed ──────────────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 340),
              child: GradientButton(
                label: _isConfirming
                    ? 'Verifying Payment...'
                    : 'I Have Completed Payment',
                iconAsset: _isConfirming ? null : AppIcons.checkCircle,
                loading: _isConfirming,
                onPressed: _isConfirming ? null : _onConfirmPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
