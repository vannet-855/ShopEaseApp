import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock/models/address_model.dart';

class AddressNotifier extends Notifier<List<AddressModel>> {
  @override
  List<AddressModel> build() => mockAddresses;

  void addAddress(AddressModel newAddress) {
    if (newAddress.isDefault) {
      state = [
        ...state.map((a) => a.copyWith(isDefault: false)),
        newAddress,
      ];
    } else {
      state = [...state, newAddress];
    }
  }

  void updateAddress(AddressModel updated) {
    state = state.map((a) {
      if (a.id == updated.id) {
        return updated;
      }
      return updated.isDefault ? a.copyWith(isDefault: false) : a;
    }).toList();
  }

  void deleteAddress(String id) {
    state = state.where((a) => a.id != id).toList();
    if (state.isNotEmpty && !state.any((a) => a.isDefault)) {
      state = [
        state.first.copyWith(isDefault: true),
        ...state.skip(1),
      ];
    }
  }

  void setDefault(String id) {
    state = state.map((a) => a.copyWith(isDefault: a.id == id)).toList();
  }
}

final addressProvider =
    NotifierProvider<AddressNotifier, List<AddressModel>>(AddressNotifier.new);

final selectedAddressIdProvider =
    NotifierProvider<_SelectedAddressIdNotifier, String?>(
  _SelectedAddressIdNotifier.new,
);

class _SelectedAddressIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final addresses = ref.watch(addressProvider);
    final def = addresses.where((a) => a.isDefault);
    return def.isNotEmpty ? def.first.id : (addresses.isNotEmpty ? addresses.first.id : null);
  }

  void select(String id) => state = id;
}

final activeShippingAddressProvider = Provider<AddressModel?>((ref) {
  final addresses = ref.watch(addressProvider);
  final selectedId = ref.watch(selectedAddressIdProvider);
  if (selectedId == null && addresses.isNotEmpty) return addresses.first;
  try {
    return addresses.firstWhere((a) => a.id == selectedId);
  } catch (_) {
    return addresses.isNotEmpty ? addresses.first : null;
  }
});
