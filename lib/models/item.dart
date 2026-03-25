// Domain models used across the AirXpert app.

class Product {
  final String id;
  final String name;
  final String nameTa;
  final String description;
  final String descriptionTa;
  final double price;
  final String imageUrl;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.nameTa,
    required this.description,
    required this.descriptionTa,
    required this.price,
    required this.imageUrl,
    this.inStock = true,
  });

  Map<String, dynamic> toMap() => {
        '_id': id,
        'id': id,
        'name': name,
        'nameTa': nameTa,
        'description': description,
        'descriptionTa': descriptionTa,
        'price': price,
        'imageUrl': imageUrl,
        'inStock': inStock,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        nameTa: map['nameTa'] ?? '',
        description: map['description'] ?? '',
        descriptionTa: map['descriptionTa'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: map['imageUrl'] ?? '',
        inStock: map['inStock'] ?? true,
      );
}

class SparePart {
  final String id;
  final String name;
  final String nameTa;
  final String description;
  final String descriptionTa;
  final double price;
  final String imageUrl;
  final bool inStock;

  const SparePart({
    required this.id,
    required this.name,
    required this.nameTa,
    required this.description,
    required this.descriptionTa,
    required this.price,
    required this.imageUrl,
    this.inStock = true,
  });

  Map<String, dynamic> toMap() => {
        '_id': id,
        'id': id,
        'name': name,
        'nameTa': nameTa,
        'description': description,
        'descriptionTa': descriptionTa,
        'price': price,
        'imageUrl': imageUrl,
        'inStock': inStock,
      };

  factory SparePart.fromMap(Map<String, dynamic> map) => SparePart(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        nameTa: map['nameTa'] ?? '',
        description: map['description'] ?? '',
        descriptionTa: map['descriptionTa'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: map['imageUrl'] ?? '',
        inStock: map['inStock'] ?? true,
      );
}

class ServiceType {
  final String id;
  final String name;
  final String nameTa;
  final String description;
  final String descriptionTa;
  final double price;

  const ServiceType({
    required this.id,
    required this.name,
    required this.nameTa,
    required this.description,
    required this.descriptionTa,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        '_id': id,
        'id': id,
        'name': name,
        'nameTa': nameTa,
        'description': description,
        'descriptionTa': descriptionTa,
        'price': price,
      };

  factory ServiceType.fromMap(Map<String, dynamic> map) => ServiceType(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        nameTa: map['nameTa'] ?? '',
        description: map['description'] ?? '',
        descriptionTa: map['descriptionTa'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
      );
}

class CartItem {
  final String id;
  final String name;
  final String nameTa;
  final double price;
  final String type;
  final int quantity;
  final String? imageUrl;

  const CartItem({
    required this.id,
    required this.name,
    required this.nameTa,
    required this.price,
    required this.type,
    this.quantity = 1,
    this.imageUrl,
  });

  CartItem copyWith({int? quantity, String? imageUrl}) => CartItem(
        id: id,
        name: name,
        nameTa: nameTa,
        price: price,
        type: type,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}

class BillItem {
  final String name;
  final String nameTa;
  final double price;
  final String type;

  const BillItem({
    required this.name,
    required this.nameTa,
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'service': service.toMap(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'] ?? '',
        customerName: map['customerName'] ?? '',
        phone: map['phone'] ?? '',
        address: map['address'] ?? '',
        service: ServiceType.fromMap(map['service'] ?? {}),
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime date;
  final String method;

  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'method': method,
      };

  factory PaymentRecord.fromMap(Map<String, dynamic> map) => PaymentRecord(
        id: map['id'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        method: map['method'] ?? '',
      );
}

class OrderItem {
  final String refId;
  final String name;
  final String nameTa;
  final String type;
  final double price;
  final int quantity;

  const OrderItem({
    required this.refId,
    required this.name,
    required this.nameTa,
    required this.type,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
        'refId': refId,
        'name': name,
        'nameTa': nameTa,
        'type': type,
        'price': price,
        'quantity': quantity,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        refId: map['refId'] ?? '',
        name: map['name'] ?? '',
        nameTa: map['nameTa'] ?? '',
        type: map['type'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        quantity: map['quantity'] ?? 1,
      );
}

class Order {
  final String id;
  final String userEmail;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double total;
  String status;

  Order({
    required this.id,
    required this.userEmail,
    required this.createdAt,
    required this.items,
    required this.total,
    this.status = 'placed',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((it) => it.toMap()).toList(),
        'total': total,
        'status': status,
      };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['id'] ?? '',
        userEmail: map['userEmail'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        items: (map['items'] as List?)
                ?.map((it) => OrderItem.fromMap(it))
                .toList() ??
            [],
        total: (map['total'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] ?? 'placed',
      );
}

class FeedbackEntry {
  final String id;
  final String userName;
  final String userEmail;
  final String message;
  final int rating;
  final DateTime createdAt;

  const FeedbackEntry({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.message,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userName': userName,
        'userEmail': userEmail,
        'message': message,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FeedbackEntry.fromMap(Map<String, dynamic> map) => FeedbackEntry(
        id: map['id'] ?? '',
        userName: map['userName'] ?? '',
        userEmail: map['userEmail'] ?? '',
        message: map['message'] ?? '',
        rating: map['rating'] ?? 5,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );
}
