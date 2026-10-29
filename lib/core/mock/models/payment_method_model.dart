enum PaymentType {
  khqr,
  visa,
  mastercard,
  googlePay,
  applePay,
  paypal,
  cashOnDelivery,
  bankTransfer,
}

class PaymentMethodModel {
  final String id;
  final PaymentType type;
  final String title;
  final String last4;
  final String cardHolder;
  final String expiry;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.last4,
    required this.cardHolder,
    required this.expiry,
    this.isDefault = false,
  });

  String get maskedNumber {
    if (type == PaymentType.khqr) return 'Scan with any Cambodian Banking App';
    if (type == PaymentType.cashOnDelivery) return 'Pay when your order arrives';
    if (type == PaymentType.bankTransfer) return 'Transfer from your banking app';
    if (type == PaymentType.googlePay || type == PaymentType.applePay || type == PaymentType.paypal) {
      return last4;
    }
    return '•••• •••• •••• $last4';
  }

  PaymentMethodModel copyWith({
    String? id,
    PaymentType? type,
    String? title,
    String? last4,
    String? cardHolder,
    String? expiry,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      last4: last4 ?? this.last4,
      cardHolder: cardHolder ?? this.cardHolder,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

const mockPaymentMethods = [
  PaymentMethodModel(
    id: 'pay_khqr',
    type: PaymentType.khqr,
    title: 'KHQR Payment (Bakong / ABA / ACLEDA)',
    last4: 'KHQR',
    cardHolder: 'ShopEase Merchant',
    expiry: '--/--',
    isDefault: true,
  ),
  PaymentMethodModel(
    id: 'pay_1',
    type: PaymentType.visa,
    title: 'Chase Sapphire Preferred',
    last4: '4242',
    cardHolder: 'ALEX JOHNSON',
    expiry: '08/28',
    isDefault: false,
  ),
  PaymentMethodModel(
    id: 'pay_2',
    type: PaymentType.mastercard,
    title: 'Apple Card Mastercard',
    last4: '8812',
    cardHolder: 'ALEX JOHNSON',
    expiry: '11/27',
    isDefault: false,
  ),
  PaymentMethodModel(
    id: 'pay_3',
    type: PaymentType.googlePay,
    title: 'Google Pay',
    last4: '1934',
    cardHolder: 'Alex Johnson',
    expiry: '--/--',
    isDefault: false,
  ),
  PaymentMethodModel(
    id: 'pay_4',
    type: PaymentType.paypal,
    title: 'PayPal Wallet',
    last4: 'alex@email.com',
    cardHolder: 'Alex Johnson',
    expiry: '--/--',
    isDefault: false,
  ),
];
