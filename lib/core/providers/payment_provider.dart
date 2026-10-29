import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock/models/payment_method_model.dart';

class PaymentNotifier extends Notifier<List<PaymentMethodModel>> {
  @override
  List<PaymentMethodModel> build() => mockPaymentMethods;

  void addPaymentMethod(PaymentMethodModel newMethod) {
    if (newMethod.isDefault) {
      state = [
        ...state.map((m) => m.copyWith(isDefault: false)),
        newMethod,
      ];
    } else {
      state = [...state, newMethod];
    }
  }

  void deletePaymentMethod(String id) {
    state = state.where((m) => m.id != id).toList();
    if (state.isNotEmpty && !state.any((m) => m.isDefault)) {
      state = [
        state.first.copyWith(isDefault: true),
        ...state.skip(1),
      ];
    }
  }

  void setDefault(String id) {
    state = state.map((m) => m.copyWith(isDefault: m.id == id)).toList();
  }
}

final paymentMethodProvider =
    NotifierProvider<PaymentNotifier, List<PaymentMethodModel>>(
  PaymentNotifier.new,
);

class _SelectedPaymentIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final list = ref.watch(paymentMethodProvider);
    final def = list.where((m) => m.isDefault);
    return def.isNotEmpty ? def.first.id : (list.isNotEmpty ? list.first.id : null);
  }

  void select(String id) => state = id;
}

final selectedPaymentIdProvider =
    NotifierProvider<_SelectedPaymentIdNotifier, String?>(
  _SelectedPaymentIdNotifier.new,
);

final activePaymentMethodProvider = Provider<PaymentMethodModel?>((ref) {
  final list = ref.watch(paymentMethodProvider);
  final selectedId = ref.watch(selectedPaymentIdProvider);
  if (selectedId == null && list.isNotEmpty) return list.first;
  try {
    return list.firstWhere((m) => m.id == selectedId);
  } catch (_) {
    return list.isNotEmpty ? list.first : null;
  }
});
