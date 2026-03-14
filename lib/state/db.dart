import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/item.dart';

class AirXpertDb {
  static final AirXpertDb instance = AirXpertDb._internal();
  AirXpertDb._internal();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'airxpert.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE users(id TEXT PRIMARY KEY, name TEXT, email TEXT, password TEXT, role TEXT)');
        await db.execute('CREATE TABLE products(id TEXT PRIMARY KEY, name TEXT, description TEXT, price REAL, imageUrl TEXT, inStock INTEGER)');
        await db.execute('CREATE TABLE spares(id TEXT PRIMARY KEY, name TEXT, description TEXT, price REAL, imageUrl TEXT, inStock INTEGER)');
        await db.execute('CREATE TABLE services(id TEXT PRIMARY KEY, name TEXT, description TEXT, price REAL)');
        await db.execute('CREATE TABLE wishlist(id TEXT PRIMARY KEY)');
        await db.execute('CREATE TABLE orders(id TEXT PRIMARY KEY, userEmail TEXT, createdAt INTEGER, total REAL, status TEXT)');
        await db.execute('CREATE TABLE order_items(orderId TEXT, refId TEXT, name TEXT, type TEXT, price REAL, quantity INTEGER)');
        await db.execute('CREATE TABLE bookings(id TEXT PRIMARY KEY, customerName TEXT, phone TEXT, address TEXT, serviceId TEXT, serviceName TEXT, servicePrice REAL, createdAt INTEGER)');
        await db.execute('CREATE TABLE payments(id TEXT PRIMARY KEY, amount REAL, date INTEGER, method TEXT)');
      },
    );
  }

  Future<bool> isCatalogEmpty() async {
    final db = _db!;
    final res1 = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    final res2 = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM spares'));
    final res3 = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM services'));
    return (res1 ?? 0) == 0 && (res2 ?? 0) == 0 && (res3 ?? 0) == 0;
  }

  Future<void> insertUser(String id, String name, String email, String password, String role) async {
    final db = _db!;
    await db.insert('users', {'id': id, 'name': name, 'email': email, 'password': password, 'role': role}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, Object?>>> loadUsers() async {
    final db = _db!;
    return db.query('users');
  }

  Future<void> insertProduct(Product p) async {
    final db = _db!;
    await db.insert('products', {'id': p.id, 'name': p.name, 'description': p.description, 'price': p.price, 'imageUrl': p.imageUrl, 'inStock': p.inStock ? 1 : 0}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProduct(Product p) async {
    final db = _db!;
    await db.update('products', {'name': p.name, 'description': p.description, 'price': p.price, 'imageUrl': p.imageUrl, 'inStock': p.inStock ? 1 : 0}, where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deleteProduct(String id) async {
    final db = _db!;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> loadProducts() async {
    final db = _db!;
    final rows = await db.query('products');
    return rows
        .map((r) => Product(
              id: r['id'] as String,
              name: r['name'] as String,
              description: r['description'] as String,
              price: (r['price'] as num).toDouble(),
              imageUrl: r['imageUrl'] as String,
              inStock: (r['inStock'] as int) == 1,
            ))
        .toList();
  }

  Future<void> insertSpare(SparePart s) async {
    final db = _db!;
    await db.insert('spares', {'id': s.id, 'name': s.name, 'description': s.description, 'price': s.price, 'imageUrl': s.imageUrl, 'inStock': s.inStock ? 1 : 0}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSpare(SparePart s) async {
    final db = _db!;
    await db.update('spares', {'name': s.name, 'description': s.description, 'price': s.price, 'imageUrl': s.imageUrl, 'inStock': s.inStock ? 1 : 0}, where: 'id = ?', whereArgs: [s.id]);
  }

  Future<void> deleteSpare(String id) async {
    final db = _db!;
    await db.delete('spares', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SparePart>> loadSpares() async {
    final db = _db!;
    final rows = await db.query('spares');
    return rows
        .map((r) => SparePart(
              id: r['id'] as String,
              name: r['name'] as String,
              description: r['description'] as String,
              price: (r['price'] as num).toDouble(),
              imageUrl: r['imageUrl'] as String,
              inStock: (r['inStock'] as int) == 1,
            ))
        .toList();
  }

  Future<void> insertService(ServiceType s) async {
    final db = _db!;
    await db.insert('services', {'id': s.id, 'name': s.name, 'description': s.description, 'price': s.price}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateService(ServiceType s) async {
    final db = _db!;
    await db.update('services', {'name': s.name, 'description': s.description, 'price': s.price}, where: 'id = ?', whereArgs: [s.id]);
  }

  Future<void> deleteService(String id) async {
    final db = _db!;
    await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ServiceType>> loadServices() async {
    final db = _db!;
    final rows = await db.query('services');
    return rows
        .map((r) => ServiceType(
              id: r['id'] as String,
              name: r['name'] as String,
              description: r['description'] as String,
              price: (r['price'] as num).toDouble(),
            ))
        .toList();
  }

  Future<void> setWishlist(Set<String> ids) async {
    final db = _db!;
    final batch = db.batch();
    await db.delete('wishlist');
    for (final id in ids) {
      batch.insert('wishlist', {'id': id});
    }
    await batch.commit(noResult: true);
  }

  Future<Set<String>> loadWishlist() async {
    final db = _db!;
    final rows = await db.query('wishlist');
    return rows.map((e) => e['id'] as String).toSet();
  }

  Future<void> insertOrder(Order o) async {
    final db = _db!;
    await db.insert('orders', {'id': o.id, 'userEmail': o.userEmail, 'createdAt': o.createdAt.millisecondsSinceEpoch, 'total': o.total, 'status': o.status}, conflictAlgorithm: ConflictAlgorithm.replace);
    final batch = db.batch();
    for (final it in o.items) {
      batch.insert('order_items', {'orderId': o.id, 'refId': it.refId, 'name': it.name, 'type': it.type, 'price': it.price, 'quantity': it.quantity});
    }
    await batch.commit(noResult: true);
  }

  Future<List<Order>> loadOrders() async {
    final db = _db!;
    final rows = await db.query('orders');
    final itemsRows = await db.query('order_items');
    final itemsByOrder = <String, List<OrderItem>>{};
    for (final r in itemsRows) {
      final orderId = r['orderId'] as String;
      (itemsByOrder[orderId] ??= []).add(OrderItem(refId: r['refId'] as String, name: r['name'] as String, type: r['type'] as String, price: (r['price'] as num).toDouble(), quantity: r['quantity'] as int));
    }
    return rows
        .map((r) => Order(
              id: r['id'] as String,
              userEmail: r['userEmail'] as String,
              createdAt: DateTime.fromMillisecondsSinceEpoch(r['createdAt'] as int),
              items: itemsByOrder[r['id'] as String] ?? const [],
              total: (r['total'] as num).toDouble(),
              status: r['status'] as String,
            ))
        .toList();
  }

  Future<void> insertBooking(Booking b) async {
    final db = _db!;
    await db.insert('bookings', {'id': b.id, 'customerName': b.customerName, 'phone': b.phone, 'address': b.address, 'serviceId': b.service.id, 'serviceName': b.service.name, 'servicePrice': b.service.price, 'createdAt': b.createdAt.millisecondsSinceEpoch}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Booking>> loadBookings() async {
    final db = _db!;
    final rows = await db.query('bookings');
    return rows
        .map((r) => Booking(
              id: r['id'] as String,
              customerName: r['customerName'] as String,
              phone: r['phone'] as String,
              address: r['address'] as String,
              service: ServiceType(id: r['serviceId'] as String, name: r['serviceName'] as String, description: '', price: (r['servicePrice'] as num).toDouble()),
              createdAt: DateTime.fromMillisecondsSinceEpoch(r['createdAt'] as int),
            ))
        .toList();
  }

  Future<void> insertPayment(PaymentRecord p) async {
    final db = _db!;
    await db.insert('payments', {'id': p.id, 'amount': p.amount, 'date': p.date.millisecondsSinceEpoch, 'method': p.method}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PaymentRecord>> loadPayments() async {
    final db = _db!;
    final rows = await db.query('payments');
    return rows
        .map((r) => PaymentRecord(
              id: r['id'] as String,
              amount: (r['amount'] as num).toDouble(),
              date: DateTime.fromMillisecondsSinceEpoch(r['date'] as int),
              method: r['method'] as String,
            ))
        .toList();
  }
}
