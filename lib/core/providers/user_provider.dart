import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock/models/user_model.dart';

class UserNotifier extends Notifier<UserModel> {
  @override
  UserModel build() => mockUser;

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    state = UserModel(
      id: state.id,
      name: name ?? state.name,
      email: email ?? state.email,
      phone: phone ?? state.phone,
      avatarUrl: avatarUrl ?? state.avatarUrl,
    );
  }
}

final userProvider = NotifierProvider<UserNotifier, UserModel>(
  UserNotifier.new,
);
