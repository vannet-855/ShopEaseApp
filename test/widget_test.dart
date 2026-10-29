import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopease_ecommerce/core/mock/models/address_model.dart';
import 'package:shopease_ecommerce/core/mock/models/payment_method_model.dart';
import 'package:shopease_ecommerce/core/mock/models/product_model.dart';
import 'package:shopease_ecommerce/core/mock/models/order_model.dart';
import 'package:shopease_ecommerce/core/providers/address_provider.dart';
import 'package:shopease_ecommerce/core/providers/cart_provider.dart';
import 'package:shopease_ecommerce/core/providers/order_provider.dart';
import 'package:shopease_ecommerce/core/providers/payment_provider.dart';
import 'package:shopease_ecommerce/core/providers/product_provider.dart';
import 'package:shopease_ecommerce/core/providers/user_provider.dart';
import 'package:shopease_ecommerce/features/checkout/checkout_screen.dart';
import 'package:shopease_ecommerce/features/checkout/khqr_payment_screen.dart';
import 'package:shopease_ecommerce/features/checkout/order_success_screen.dart';

void main() {
  group('CartNotifier tests', () {
    test('starts with empty cart', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
      expect(container.read(cartItemCountProvider), 0);
      expect(container.read(cartSubtotalProvider), 0.0);
    });

    test('adds items and increases quantity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final p = mockProducts.first;
      container.read(cartProvider.notifier).addItem(p);

      var items = container.read(cartProvider);
      expect(items.length, 1);
      expect(items.first.quantity, 1);
      expect(items.first.product.id, p.id);
      expect(container.read(cartItemCountProvider), 1);
      expect(container.read(cartSubtotalProvider), p.price);

      // Add same item again -> increments quantity
      container.read(cartProvider.notifier).addItem(p);
      items = container.read(cartProvider);
      expect(items.length, 1);
      expect(items.first.quantity, 2);
      expect(container.read(cartItemCountProvider), 2);
      expect(container.read(cartSubtotalProvider), p.price * 2);
    });

    test('updates quantity and removes when zero', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final p = mockProducts.first;
      container.read(cartProvider.notifier).addItem(p);
      container.read(cartProvider.notifier).updateQuantity(p.id, 5);

      expect(container.read(cartItemCountProvider), 5);

      container.read(cartProvider.notifier).updateQuantity(p.id, 0);
      expect(container.read(cartProvider), isEmpty);
    });

    test('removes item and clears cart', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addItem(mockProducts[0]);
      container.read(cartProvider.notifier).addItem(mockProducts[1]);
      expect(container.read(cartProvider).length, 2);

      container.read(cartProvider.notifier).removeItem(mockProducts[0].id);
      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartProvider).first.product.id, mockProducts[1].id);

      container.read(cartProvider.notifier).clear();
      expect(container.read(cartProvider), isEmpty);
    });
  });

  group('OrderNotifier tests', () {
    test('initializes with mock orders', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final orders = container.read(orderProvider);
      expect(orders.isNotEmpty, true);
    });

    test('creates order and clears cart', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final p = mockProducts.first;
      container.read(cartProvider.notifier).addItem(p);
      final items = container.read(cartProvider);
      final address = mockAddresses.first;
      final payment = mockPaymentMethods.first;

      final initialOrderCount = container.read(orderProvider).length;

      final newOrder = container.read(orderProvider.notifier).createOrder(
        items: items,
        deliveryAddress: address,
        paymentMethod: payment,
        shippingFee: 0.0,
        discount: 10.0,
      );

      expect(newOrder.id.startsWith('SE-'), true);
      expect(newOrder.status, OrderStatus.processing);
      expect(newOrder.total, (p.price - 10.0).clamp(0.0, double.infinity));
      expect(container.read(orderProvider).length, initialOrderCount + 1);
      expect(container.read(orderProvider).first.id, newOrder.id);

      // Cart should be emptied automatically
      expect(container.read(cartProvider), isEmpty);
    });

    test('cancels order by id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final orders = container.read(orderProvider);
      final targetId = orders.first.id;

      container.read(orderProvider.notifier).cancelOrder(targetId);

      final updated = container.read(orderProvider);
      final order = updated.firstWhere((o) => o.id == targetId);
      expect(order.status, OrderStatus.cancelled);
    });
  });

  group('AddressNotifier tests', () {
    test('adds, sets default, and deletes address', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const newAddr = AddressModel(
        id: 'addr_test',
        name: 'Jane Doe',
        label: 'Work',
        phone: '+1 555-4321',
        street: '456 Market St',
        city: 'San Francisco',
        state: 'CA',
        zipCode: '94105',
        isDefault: true,
      );

      container.read(addressProvider.notifier).addAddress(newAddr);
      var addresses = container.read(addressProvider);
      expect(addresses.any((a) => a.id == 'addr_test'), true);

      final defaultAddr = addresses.firstWhere((a) => a.id == 'addr_test');
      expect(defaultAddr.isDefault, true);

      // Delete address
      container.read(addressProvider.notifier).deleteAddress('addr_test');
      addresses = container.read(addressProvider);
      expect(addresses.any((a) => a.id == 'addr_test'), false);
    });
  });

  group('PaymentNotifier tests', () {
    test('adds and deletes payment method', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const newPay = PaymentMethodModel(
        id: 'pay_test',
        type: PaymentType.visa,
        title: 'Barclays Visa',
        last4: '9999',
        cardHolder: 'JANE DOE',
        expiry: '09/29',
        isDefault: false,
      );

      container.read(paymentMethodProvider.notifier).addPaymentMethod(newPay);
      var list = container.read(paymentMethodProvider);
      expect(list.any((p) => p.id == 'pay_test'), true);

      container.read(paymentMethodProvider.notifier).deletePaymentMethod('pay_test');
      list = container.read(paymentMethodProvider);
      expect(list.any((p) => p.id == 'pay_test'), false);
    });
  });

  group('UserNotifier tests', () {
    test('updates user profile correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(userProvider);
      expect(initial.name, 'Alex Johnson');

      container.read(userProvider.notifier).updateProfile(
        name: 'Alexander Great',
        email: 'alex.great@email.com',
      );

      final updated = container.read(userProvider);
      expect(updated.name, 'Alexander Great');
      expect(updated.email, 'alex.great@email.com');
      expect(updated.phone, initial.phone); // Unchanged
    });
  });

  group('WishlistNotifier tests', () {
    test('toggles products in wishlist', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);
      expect(container.read(wishlistProvider), isEmpty);
      expect(notifier.isWishlisted('p1'), false);

      notifier.toggle('p1');
      expect(container.read(wishlistProvider).contains('p1'), true);
      expect(notifier.isWishlisted('p1'), true);

      notifier.toggle('p2');
      expect(container.read(wishlistProvider).length, 2);

      notifier.toggle('p1');
      expect(container.read(wishlistProvider).contains('p1'), false);
      expect(container.read(wishlistProvider).length, 1);
    });
  });

  group('JSON Model Serialization tests', () {
    test('ProductModel parses and serializes correctly', () {
      final json = {
        'id': 'test_p1',
        'title': 'Test Shoe',
        'description': 'A great test shoe',
        'price': 99.99,
        'originalPrice': 129.99,
        'imageUrl': 'https://example.com/shoe.jpg',
        'images': ['https://example.com/shoe1.jpg'],
        'categoryId': 'shoes',
        'brand': 'Nike',
        'rating': 4.5,
        'reviewCount': 50,
        'stock': 10,
        'isFeatured': true,
        'isActive': true,
        'tags': ['running', 'sale'],
        'sizes': ['9', '10'],
        'colors': ['Black'],
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, 'test_p1');
      expect(product.title, 'Test Shoe');
      expect(product.price, 99.99);
      expect(product.hasDiscount, true);
      expect(product.discountPercent, closeTo(23.07, 0.1));

      final serialized = product.toJson();
      expect(serialized['id'], 'test_p1');
      expect(serialized['price'], 99.99);
      expect(serialized['tags'], ['running', 'sale']);
    });
  });

  group('CheckoutScreen Widget tests', () {
    testWidgets('renders CheckoutScreen with items', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      container.read(cartProvider.notifier).addItem(mockProducts.first);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('Delivery Options'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('renders KHQRPaymentScreen with timer and actions', (tester) async {
      final order = mockOrders.first;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: KHQRPaymentScreen(order: order),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pay with KHQR'), findsOneWidget);
      expect(find.text('Amount due to ShopEase Cambodia'), findsOneWidget);
      expect(find.text('Save QR'), findsOneWidget);
      expect(find.text('I Have Completed Payment'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('renders OrderSuccessScreen with celebration and timeline', (tester) async {
      final order = mockOrders.first;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: OrderSuccessScreen(order: order),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Order confirmed!'), findsOneWidget);
      expect(find.text('Track Order'), findsOneWidget);
      expect(find.text('Continue Shopping'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}

