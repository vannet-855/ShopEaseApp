import 'cart_item_model.dart';
import 'address_model.dart';
import 'payment_method_model.dart';
import 'product_model.dart';

enum OrderStatus {
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderTimelineStep {
  final String title;
  final String description;
  final String time;
  final bool isCompleted;
  final bool isCurrent;

  const OrderTimelineStep({
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    this.isCurrent = false,
  });
}

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final AddressModel deliveryAddress;
  final PaymentMethodModel paymentMethod;
  final DateTime createdAt;
  final DateTime estimatedDelivery;
  final List<OrderTimelineStep> trackingSteps;

  const OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    required this.estimatedDelivery,
    required this.trackingSteps,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  String get statusLabel {
    switch (status) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    double? subtotal,
    double? shippingFee,
    double? discount,
    double? total,
    OrderStatus? status,
    AddressModel? deliveryAddress,
    PaymentMethodModel? paymentMethod,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    List<OrderTimelineStep>? trackingSteps,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingSteps: trackingSteps ?? this.trackingSteps,
    );
  }
}

final mockOrders = [
  OrderModel(
    id: 'SE-984210',
    items: [
      CartItemModel(product: mockProducts[0], quantity: 1),
      CartItemModel(product: mockProducts[2], quantity: 2),
    ],
    subtotal: mockProducts[0].price + (mockProducts[2].price * 2),
    shippingFee: 0.0,
    discount: 25.0,
    total: mockProducts[0].price + (mockProducts[2].price * 2) - 25.0,
    status: OrderStatus.shipped,
    deliveryAddress: mockAddresses[0],
    paymentMethod: mockPaymentMethods[0],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
    trackingSteps: const [
      OrderTimelineStep(
        title: 'Order Confirmed',
        description: 'Your order has been verified and received by ShopEase',
        time: 'Oct 08, 09:30 AM',
        isCompleted: true,
      ),
      OrderTimelineStep(
        title: 'Packed & Processed',
        description: 'Item carefully inspected and wrapped in protective box',
        time: 'Oct 08, 04:15 PM',
        isCompleted: true,
      ),
      OrderTimelineStep(
        title: 'In Transit',
        description: 'Package left sorting facility in Portland, OR',
        time: 'Oct 09, 11:20 AM',
        isCompleted: true,
        isCurrent: true,
      ),
      OrderTimelineStep(
        title: 'Out for Delivery',
        description: 'Courier driver assigned for same-day delivery',
        time: 'Expected tomorrow',
        isCompleted: false,
      ),
      OrderTimelineStep(
        title: 'Delivered',
        description: 'Package handed directly or placed at front door',
        time: 'Pending',
        isCompleted: false,
      ),
    ],
  ),
  OrderModel(
    id: 'SE-871932',
    items: [
      CartItemModel(product: mockProducts[1], quantity: 1),
    ],
    subtotal: mockProducts[1].price,
    shippingFee: 9.99,
    discount: 0.0,
    total: mockProducts[1].price + 9.99,
    status: OrderStatus.delivered,
    deliveryAddress: mockAddresses[0],
    paymentMethod: mockPaymentMethods[1],
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
    estimatedDelivery: DateTime.now().subtract(const Duration(days: 9)),
    trackingSteps: const [
      OrderTimelineStep(
        title: 'Order Placed',
        description: 'Payment authorized via Apple Card',
        time: 'Sep 28, 10:15 AM',
        isCompleted: true,
      ),
      OrderTimelineStep(
        title: 'Delivered',
        description: 'Left at front porch. Signed by ALEX',
        time: 'Oct 01, 02:40 PM',
        isCompleted: true,
        isCurrent: true,
      ),
    ],
  ),
  OrderModel(
    id: 'SE-654219',
    items: [
      CartItemModel(product: mockProducts[4], quantity: 1),
      CartItemModel(product: mockProducts[5], quantity: 1),
    ],
    subtotal: mockProducts[4].price + mockProducts[5].price,
    shippingFee: 0.0,
    discount: 15.0,
    total: mockProducts[4].price + mockProducts[5].price - 15.0,
    status: OrderStatus.processing,
    deliveryAddress: mockAddresses[1],
    paymentMethod: mockPaymentMethods[2],
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
    trackingSteps: const [
      OrderTimelineStep(
        title: 'Order Received',
        description: 'Preparing your items at fulfillment hub',
        time: 'Today, 12:20 PM',
        isCompleted: true,
        isCurrent: true,
      ),
      OrderTimelineStep(
        title: 'Shipment Dispatch',
        description: 'Package ready to hand over to carrier',
        time: 'Expected tomorrow morning',
        isCompleted: false,
      ),
    ],
  ),
];
