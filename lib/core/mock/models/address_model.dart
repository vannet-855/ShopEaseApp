class AddressModel {
  final String id;
  final String name;
  final String label; // 'Home', 'Work', 'Other'
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.name,
    required this.label,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'United States',
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $state $zipCode, $country';

  AddressModel copyWith({
    String? id,
    String? name,
    String? label,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

const mockAddresses = [
  AddressModel(
    id: 'addr_1',
    name: 'Alex Johnson',
    label: 'Home',
    phone: '+1 (555) 012-3456',
    street: '742 Evergreen Terrace',
    city: 'Springfield',
    state: 'OR',
    zipCode: '97477',
    isDefault: true,
  ),
  AddressModel(
    id: 'addr_2',
    name: 'Alex Johnson',
    label: 'Work',
    phone: '+1 (555) 987-6543',
    street: '100 Innovation Way, Suite 400',
    city: 'Portland',
    state: 'OR',
    zipCode: '97201',
    isDefault: false,
  ),
];
