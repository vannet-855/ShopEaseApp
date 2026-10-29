import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock/models/payment_method_model.dart';
import '../../core/providers/payment_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    final numberCtrl = TextEditingController();
    final holderCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    PaymentType selectedType = PaymentType.visa;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Add Payment Card', style: AppTextStyles.h3),
                  const SizedBox(height: 16),

                  // Card Type selection
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Visa'),
                        selected: selectedType == PaymentType.visa,
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() => selectedType = PaymentType.visa);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Mastercard'),
                        selected: selectedType == PaymentType.mastercard,
                        onSelected: (val) {
                          if (val) {
                            setSheetState(
                                () => selectedType = PaymentType.mastercard);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: numberCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      hintText: '1234 5678 9012 3456',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: holderCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Cardholder Name',
                      hintText: 'JOHN DOE',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: expiryCtrl,
                          keyboardType: TextInputType.datetime,
                          maxLength: 5,
                          decoration: InputDecoration(
                            labelText: 'Expiry (MM/YY)',
                            hintText: '12/28',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: cvvCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  GradientButton(
                    label: 'Save Card',
                    onPressed: () {
                      final numText = numberCtrl.text.trim();
                      final holderText = holderCtrl.text.trim();
                      final expText = expiryCtrl.text.trim();

                      if (numText.length < 4 || holderText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all card fields correctly'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final last4 = numText.length >= 4
                          ? numText.substring(numText.length - 4)
                          : '1234';

                      final newCard = PaymentMethodModel(
                        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                        type: selectedType,
                        title: selectedType == PaymentType.visa
                            ? 'Visa Card'
                            : 'Mastercard',
                        last4: last4,
                        cardHolder: holderText.toUpperCase(),
                        expiry: expText.isEmpty ? '12/28' : expText,
                        isDefault: false,
                      );

                      ref
                          .read(paymentMethodProvider.notifier)
                          .addPaymentMethod(newCard);

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Card added successfully!'),
                          backgroundColor: AppColors.secondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(paymentMethodProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved Cards', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            ...methods.map((method) {
              final isCard = method.type == PaymentType.visa ||
                  method.type == PaymentType.mastercard;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: isCard
                      ? LinearGradient(
                          colors: method.type == PaymentType.visa
                              ? const [Color(0xFF1E3A8A), Color(0xFF3B82F6)]
                              : const [Color(0xFF831843), Color(0xFFF43F5E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isCard ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isCard ? null : Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: isCard
                          ? (method.type == PaymentType.visa
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFFF43F5E))
                              .withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          method.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isCard ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (method.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCard
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: AppTextStyles.caption.copyWith(
                                color: isCard
                                    ? Colors.white
                                    : AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      method.maskedNumber,
                      style: AppTextStyles.h2.copyWith(
                        letterSpacing: 2.0,
                        color: isCard ? Colors.white : AppColors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: AppTextStyles.caption.copyWith(
                                color: isCard
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : AppColors.textHint,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              method.cardHolder,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isCard
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPIRES',
                              style: AppTextStyles.caption.copyWith(
                                color: isCard
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : AppColors.textHint,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              method.expiry,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isCard
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: isCard ? Colors.white : AppColors.textHint,
                          ),
                          onSelected: (val) {
                            if (val == 'default') {
                              ref
                                  .read(paymentMethodProvider.notifier)
                                  .setDefault(method.id);
                            } else if (val == 'delete') {
                              ref
                                  .read(paymentMethodProvider.notifier)
                                  .deletePaymentMethod(method.id);
                            }
                          },
                          itemBuilder: (ctx) => [
                            if (!method.isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as Default'),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Card',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: GradientButton(
            label: 'Add New Payment Method',
            icon: Icons.add_rounded,
            onPressed: () => _showAddCardDialog(context, ref),
          ),
        ),
      ),
    );
  }
}
