/// Domain models used across the AirXpert app.
///
/// These are kept deliberately simple and in‑memory only so the
/// UI can focus on a clean, production‑style experience.

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // placeholder image

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class SparePart {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // placeholder image

  const SparePart({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class ServiceType {
  final String id;
  final String name;
  final String description;
  final double price;

  const ServiceType({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String type; // 'product', 'spare', 'service'
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) =>
      CartItem(id: id, name: name, price: price, type: type, quantity: quantity ?? this.quantity);
}

class BillItem {
  final String name;
  final double price;
  final String type; // 'service', 'product', 'spare'

  const BillItem({
    required this.name,
    required this.price,
    required this.type,
  });
}

class Booking {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final ServiceType service;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.service,
    required this.createdAt,
  });
}

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime date;
  final String method; // e.g. 'UPI', 'Card', 'Cash'

  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
  });
}

class OrderItem {
  final String refId; // product/spare/service id
  final String name;
  final String type; // 'product' | 'spare' | 'service'
  final double price;
  final int quantity;

  const OrderItem({
    required this.refId,
    required this.name,
    required this.type,
    required this.price,
    this.quantity = 1,
  });
}

class Order {
  final String id;
  final String userEmail;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double total;
  String status; // 'placed' | 'paid' | 'completed'

  Order({
    required this.id,
    required this.userEmail,
    required this.createdAt,
    required this.items,
    required this.total,
    this.status = 'placed',
  });
}
