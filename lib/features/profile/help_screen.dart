import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _FaqItem {
  final String category;
  final String q;
  final String a;
  const _FaqItem({required this.category, required this.q, required this.a});
}

class _ChatMessage {
  final bool isMe;
  final String text;
  const _ChatMessage({required this.isMe, required this.text});
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      category: 'Orders',
      q: 'How do I track my active order?',
      a: 'You can track your order at any time by heading to Profile > My Orders > Active Orders, and clicking "Track Order". You will see real-time status updates from warehouse dispatch to front door delivery.',
    ),
    _FaqItem(
      category: 'Orders',
      q: 'Can I cancel or modify an order after placing it?',
      a: 'Orders can be cancelled within 1 hour of placing them directly from the Order Details page. Once an order enters the shipping stage, it can no longer be modified, but you may initiate a return upon delivery.',
    ),
    _FaqItem(
      category: 'Shipping',
      q: 'What are the standard delivery timeframes?',
      a: 'Standard shipping typically takes 3 to 5 business days across the country. Express delivery takes 1-2 business days, and Same-Day delivery is available for orders placed before 1:00 PM in select metro areas.',
    ),
    _FaqItem(
      category: 'Shipping',
      q: 'Do you offer free shipping?',
      a: 'Yes! All orders over \$50 qualify automatically for Free Standard Shipping. ShopEase VIP members receive free express shipping on all eligible purchases.',
    ),
    _FaqItem(
      category: 'Payments',
      q: 'Which payment methods are accepted?',
      a: 'We accept Visa, Mastercard, American Express, Apple Pay, Google Pay, and PayPal. In select regions, Cash on Delivery (COD) is also available during checkout.',
    ),
    _FaqItem(
      category: 'Payments',
      q: 'Is my payment information securely processed?',
      a: 'All transactions are encrypted with 256-bit bank-level SSL encryption and processed through certified PCI-DSS Level 1 payment gateways. We never store full card numbers on our servers.',
    ),
    _FaqItem(
      category: 'Returns',
      q: 'What is your return policy?',
      a: 'We offer a 30-day hassle-free return window for all unused items in their original packaging. Simply select "Return Item" under your completed order to generate a prepaid shipping label.',
    ),
    _FaqItem(
      category: 'Returns',
      q: 'When will I receive my refund?',
      a: 'Once our fulfillment center inspects your returned package, your refund will be processed back to your original payment method within 3 to 5 business days.',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showLiveChatSheet() {
    final msgCtrl = TextEditingController();
    final messages = <_ChatMessage>[
      const _ChatMessage(
        isMe: false,
        text: 'Hello! Welcome to ShopEase Support. How can we help you today?',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setChatState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SizedBox(
              height: 480,
              child: Column(
                children: [
                  // Chat Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.support_agent_rounded,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Support Assistant',
                                style: AppTextStyles.labelLarge),
                            Text('Online • Typically replies instantly',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.secondary)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Chat Message List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (ctx, i) {
                        final m = messages[i];
                        return Align(
                          alignment: m.isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: m.isMe
                                  ? AppColors.primary
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              m.text,
                              style: TextStyle(
                                color: m.isMe
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Input Box
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: msgCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Type your question...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: AppColors.primary),
                          onPressed: () {
                            final text = msgCtrl.text.trim();
                            if (text.isEmpty) return;
                            setChatState(() {
                              messages.add(_ChatMessage(isMe: true, text: text));
                              msgCtrl.clear();
                            });
                            // Auto reply
                            Future.delayed(const Duration(milliseconds: 800), () {
                              if (ctx.mounted) {
                                setChatState(() {
                                  messages.add(
                                    const _ChatMessage(
                                      isMe: false,
                                      text:
                                          'Thanks for your message! Our representative will review your inquiry shortly.',
                                    ),
                                  );
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
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
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredFaqs = _faqs.where((f) {
      final matchesCategory =
          _selectedCategory == 'All' || f.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          f.q.toLowerCase().contains(query) ||
          f.a.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search FAQ or topics...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Orders', 'Shipping', 'Payments', 'Returns']
                    .map((cat) {
                  final sel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: sel,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textPrimary,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Frequently Asked Questions
            Text('Frequently Asked Questions', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            if (filteredFaqs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No questions match your query.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...filteredFaqs.map((faq) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(faq.q, style: AppTextStyles.labelLarge),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Text(
                        faq.a,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 32),

            // Contact Channels
            Text('Still need help?', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    subtitle: 'Chat with team',
                    color: AppColors.secondary,
                    onTap: _showLiveChatSheet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email Us',
                    subtitle: '24h turnaround',
                    color: AppColors.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support email: support@shopease.com'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.labelLarge),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
