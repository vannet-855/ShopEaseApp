import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock/models/address_model.dart';
import '../mock/models/cart_item_model.dart';
import '../mock/models/order_model.dart';
import '../mock/models/payment_method_model.dart';
import 'cart_provider.dart';

class OrderNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() => mockOrders;

  OrderModel createOrder({
    required List<CartItemModel> items,
    required AddressModel deliveryAddress,
    required PaymentMethodModel paymentMethod,
    required double shippingFee,
    required double discount,
  }) {
    final subtotal = items.fold(0.0, (sum, i) => sum + i.totalPrice);
    final total = (subtotal + shippingFee - discount).clamp(0.0, double.infinity);
    final randId = 100000 + Random().nextInt(900000);
    final orderId = 'SE-$randId';

    final newOrder = OrderModel(
      id: orderId,
      items: List.from(items),
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      total: total,
      status: OrderStatus.processing,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      trackingSteps: [
        OrderTimelineStep(
          title: 'Order Placed',
          description: 'Payment authorized via ${paymentMethod.title}',
          time: 'Just now',
          isCompleted: true,
          isCurrent: true,
        ),
        const OrderTimelineStep(
          title: 'Order Processed',
          description: 'Our warehouse is picking and packing your items',
          time: 'Pending',
          isCompleted: false,
        ),
        const OrderTimelineStep(
          title: 'Dispatched',
          description: 'Handed over to delivery carrier',
          time: 'Pending',
          isCompleted: false,
        ),
        const OrderTimelineStep(
          title: 'Delivered',
          description: 'Delivered to your destination address',
          time: 'Pending',
          isCompleted: false,
        ),
      ],
    );

    state = [newOrder, ...state];
    ref.read(cartProvider.notifier).clear();
    return newOrder;
  }

  void cancelOrder(String orderId) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: OrderStatus.cancelled);
      }
      return order;
    }).toList();
  }
}

final orderProvider =
    NotifierProvider<OrderNotifier, List<OrderModel>>(OrderNotifier.new);

final activeOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(orderProvider);
  return orders
      .where((o) =>
          o.status == OrderStatus.processing || o.status == OrderStatus.shipped)
      .toList();
});

final completedOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(orderProvider);
  return orders.where((o) => o.status == OrderStatus.delivered).toList();
});

final cancelledOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(orderProvider);
  return orders.where((o) => o.status == OrderStatus.cancelled).toList();
});
