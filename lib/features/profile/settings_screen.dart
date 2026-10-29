import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _promoAlerts = false;
  bool _biometrics = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English (US)';
  String _selectedCurrency = 'USD (\$)';

  void _showLanguageDialog() {
    final languages = ['English (US)', 'Español', 'Français', 'Deutsch', 'Khmer'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Language'),
        children: languages.map((lang) {
          return SimpleDialogOption(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            onPressed: () {
              setState(() => _selectedLanguage = lang);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang, style: AppTextStyles.bodyMedium),
                if (_selectedLanguage == lang)
                  const Icon(Icons.check, color: AppColors.primary, size: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['USD (\$)', 'EUR (€)', 'GBP (£)', 'CAD (\$)'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Currency'),
        children: currencies.map((curr) {
          return SimpleDialogOption(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            onPressed: () {
              setState(() => _selectedCurrency = curr);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(curr, style: AppTextStyles.bodyMedium),
                if (_selectedCurrency == curr)
                  const Icon(Icons.check, color: AppColors.primary, size: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of ShopEase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Notifications Section ──────────────────────────────────────────
          _SectionTitle('Notifications'),
          _SettingsContainer(children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications for deals and alerts'),
              value: _pushNotifications,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _pushNotifications = val),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Order Status Updates'),
              subtitle: const Text('Real-time updates on package delivery'),
              value: _orderUpdates,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _orderUpdates = val),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Promotions & Discounts'),
              subtitle: const Text('Exclusive sales and coupon reminders'),
              value: _promoAlerts,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _promoAlerts = val),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Preferences Section ────────────────────────────────────────────
          _SectionTitle('Preferences'),
          _SettingsContainer(children: [
            ListTile(
              title: const Text('Language'),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
              onTap: _showLanguageDialog,
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Currency'),
              subtitle: Text(_selectedCurrency),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
              onTap: _showCurrencyDialog,
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Adaptive dark aesthetic theme'),
              value: _darkMode,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _darkMode = val),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Security Section ───────────────────────────────────────────────
          _SectionTitle('Security'),
          _SettingsContainer(children: [
            SwitchListTile(
              title: const Text('Biometric Login'),
              subtitle: const Text('Use Face ID / Fingerprint to log in'),
              value: _biometrics,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _biometrics = val),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset link sent to your email'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ── App & Storage Section ──────────────────────────────────────────
          _SectionTitle('Storage & Legal'),
          _SettingsContainer(children: [
            ListTile(
              title: const Text('Clear App Cache'),
              subtitle: const Text('Free up temporary files (42 MB)'),
              trailing: const Icon(Icons.cleaning_services_rounded,
                  color: AppColors.textHint, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache successfully cleared!'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.open_in_new, color: AppColors.textHint, size: 18),
              onTap: () {},
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.open_in_new, color: AppColors.textHint, size: 18),
              onTap: () {},
            ),
            const Divider(height: 1),
            const ListTile(
              title: Text('App Version'),
              trailing: Text('1.0.0 (Build 42)',
                  style: TextStyle(color: AppColors.textHint)),
            ),
          ]),

          const SizedBox(height: 32),

          // Sign Out Action
          InkWell(
            onTap: _confirmSignOut,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTextStyles.h4),
    );
  }
}

class _SettingsContainer extends StatelessWidget {
  final List<Widget> children;
  const _SettingsContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}
