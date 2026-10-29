import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/bouncing_tap.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/figma_toast.dart';
import '../../core/mock/models/notification_model.dart';
import '../../core/providers/home_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';

/// Screen matching Figma node 86:4743 ("Notifications - All").
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _tabs = ['All', 'Orders', 'Promotions', 'System'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationModel> _filterNotifications(
      List<NotificationModel> all, int tabIndex) {
    switch (tabIndex) {
      case 1: // Orders
        return all.where((n) => n.type == 'order_update').toList();
      case 2: // Promotions
        return all.where((n) => n.type == 'promo').toList();
      case 3: // System
        return all
            .where((n) => n.type != 'order_update' && n.type != 'promo')
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const AppIcon(
            AppIcons.chevronLeft,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: AppTextStyles.h3),
        actions: [
          BouncingTap(
            onTap: () {
              ref.read(notificationProvider.notifier).markAllAsRead();
              FigmaToast.show(
                context,
                message: 'All notifications marked as read',
                iconAsset: AppIcons.check,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelMedium,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Failed to load notifications')),
        data: (notifications) {
          final filtered =
              _filterNotifications(notifications, _tabController.index);

          if (filtered.isEmpty) {
            return Center(
              child: FadeSlideIn(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: AppIcon(
                          AppIcons.bell,
                          size: 38,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('No notifications', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      "You're all caught up in this tab!",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final n = filtered[i];
              return FadeSlideIn(
                delay: Duration(milliseconds: i * 40),
                child: _NotificationTile(
                  notification: n,
                  onTap: () {
                    ref.read(notificationProvider.notifier).markAsRead(n.id);
                    if (n.deepLink != null && n.deepLink!.isNotEmpty) {
                      context.push(n.deepLink!);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  String get _iconAsset {
    switch (notification.type) {
      case 'order_update':
        return AppIcons.packageCheck;
      case 'promo':
        return AppIcons.shoppingBag;
      default:
        return AppIcons.bell;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'order_update':
        return AppColors.primary;
      case 'promo':
        return AppColors.accent;
      default:
        return const Color(0xFF21A675);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.98,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.surfaceVariant.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppIcon(
                  _iconAsset,
                  size: 20,
                  color: _iconColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
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
