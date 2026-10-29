import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock/models/banner_model.dart';
import '../mock/models/notification_model.dart';
import '../services/api_service.dart';

/// Banners fetched from JSON data source.
final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final json = await ApiService.instance.getBanners();
  return json
      .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Notifications fetched from JSON data source.
class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final json = await ApiService.instance.getNotifications();
    return json
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void markAsRead(String id) {
    state = AsyncData(
      state.value?.map((n) {
            if (n.id == id) n.isRead = true;
            return n;
          }).toList() ??
          [],
    );
  }

  void markAllAsRead() {
    state = AsyncData(
      state.value?.map((n) {
            n.isRead = true;
            return n;
          }).toList() ??
          [],
    );
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  NotificationNotifier.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
