import 'package:mongo_dart/mongo_dart.dart';
import '../models/item.dart' as m;
import 'dart:async';

class AtlasStore {
  static final AtlasStore instance = AtlasStore._internal();
  AtlasStore._internal();

  Db? _db;
  bool _available = false;
  bool get isAvailable => _available;

  // Connection string from user
  static const String connectionString =
      "mongodb+srv://Divisha:divisha2005@mern2025.aeoqbnu.mongodb.net/AirXpert?retryWrites=true&w=majority&appName=MERN2025";

  Future<void> init() async {
    try {
      print('Attempting to connect to MongoDB Atlas...');
      _db = await Db.create(connectionString);
      // Add a timeout to avoid hanging indefinitely
      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
            'Connection to MongoDB Atlas timed out. Please check your internet and IP whitelist.',
          );
        },
      );
      _available = true;
      print(
        '✅ MongoDB Atlas Connected successfully to database: ${_db!.databaseName}',
      );
    } catch (e) {
      _available = false;
      print('❌ MongoDB Atlas Connection Error: $e');
      if (e.toString().contains('IP')) {
        print(
          '💡 PRO TIP: It looks like your IP address might not be whitelisted in the MongoDB Atlas dashboard.',
        );
      }
    }
  }

  // Collections
  DbCollection get _productsColl => _db!.collection('products');
  DbCollection get _sparesColl => _db!.collection('spares');
  DbCollection get _servicesColl => _db!.collection('services');
  DbCollection get _usersColl => _db!.collection('users');
  DbCollection get _ordersColl => _db!.collection('orders');
  DbCollection get _bookingsColl => _db!.collection('bookings');
  DbCollection get _paymentsColl => _db!.collection('payments');
  DbCollection get _wishlistColl => _db!.collection('wishlist');
  DbCollection get _feedbackColl => _db!.collection('feedback');

  Future<void> _ensureOpen() async {
    if (_db == null) {
      print('🔄 DB is null, initializing...');
      await init();
    }
    if (_db != null && !_db!.isConnected) {
      print('🔄 DB disconnected, opening...');
      try {
        await _db!.open().timeout(const Duration(seconds: 10));
        _available = true;
      } catch (e) {
        _available = false;
        print('❌ Failed to re-open DB: $e');
      }
    }
  }

  // User Management
  Future<bool> insertUser(
    String id,
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      await _ensureOpen();
      if (!_available) {
        print('❌ Cannot insert user: DB not available');
        return false;
      }
      print('💾 Storing user in Atlas: $email');
      await _usersColl.update(where.eq('id', id), {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      }, upsert: true);
      print('✅ User stored successfully');
      return true;
    } catch (e) {
      print('❌ Error inserting user: $e');
      return false;
    }
  }

  Future<List<Map<String, Object?>>> loadUsers() async {
    await _ensureOpen();
    if (!_available) return [];
    return await _usersColl.find().toList();
  }

  // Catalog Management
  Future<bool> isCatalogEmpty() async {
    try {
      await _ensureOpen();
      if (!_available) {
        print('⚠️ Cannot check catalog: MongoDB not available');
        return false; // Don't seed if we can't even connect
      }
      final count = await _productsColl.count();
      print('📊 Current product count in Atlas: $count');
      return count == 0;
    } catch (e) {
      print('❌ Error checking catalog emptiness: $e');
      return false;
    }
  }

  Future<void> insertProduct(m.Product p) async {
    await _ensureOpen();
    if (!_available) return;
    await _productsColl.update(where.eq('id', p.id), p.toMap(), upsert: true);
  }

  Future<void> updateProduct(m.Product p) async {
    await _ensureOpen();
    if (!_available) return;
    await _productsColl.update(where.eq('id', p.id), p.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _ensureOpen();
    if (!_available) return;
    await _productsColl.remove(where.eq('id', id));
  }

  Stream<List<m.Product>> productsStream() {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      await _ensureOpen();
      if (!_available) return [];
      final list = await _productsColl.find().toList();
      return list.map((e) => m.Product.fromMap(e)).toList();
    });
  }

  // Spares Management
  Future<void> insertSpare(m.SparePart s) async {
    await _ensureOpen();
    if (!_available) return;
    await _sparesColl.update(where.eq('id', s.id), s.toMap(), upsert: true);
  }

  Future<void> updateSpare(m.SparePart s) async {
    await _ensureOpen();
    if (!_available) return;
    await _sparesColl.update(where.eq('id', s.id), s.toMap());
  }

  Future<void> deleteSpare(String id) async {
    await _ensureOpen();
    if (!_available) return;
    await _sparesColl.remove(where.eq('id', id));
  }

  Stream<List<m.SparePart>> sparesStream() {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      await _ensureOpen();
      if (!_available) return [];
      final list = await _sparesColl.find().toList();
      return list.map((e) => m.SparePart.fromMap(e)).toList();
    });
  }

  // Services Management
  Future<void> insertService(m.ServiceType s) async {
    await _ensureOpen();
    if (!_available) return;
    await _servicesColl.update(where.eq('id', s.id), s.toMap(), upsert: true);
  }

  Future<void> updateService(m.ServiceType s) async {
    await _ensureOpen();
    if (!_available) return;
    await _servicesColl.update(where.eq('id', s.id), s.toMap());
  }

  Future<void> deleteService(String id) async {
    await _ensureOpen();
    if (!_available) return;
    await _servicesColl.remove(where.eq('id', id));
  }

  Stream<List<m.ServiceType>> servicesStream() {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      await _ensureOpen();
      if (!_available) return [];
      final list = await _servicesColl.find().toList();
      return list.map((e) => m.ServiceType.fromMap(e)).toList();
    });
  }

  // Wishlist
  Future<void> setWishlist(Set<String> ids) async {
    await _ensureOpen();
    if (!_available) return;
    await _wishlistColl.update(where.eq('type', 'global'), {
      'type': 'global',
      'ids': ids.toList(),
    }, upsert: true);
  }

  Future<Set<String>> loadWishlist() async {
    await _ensureOpen();
    if (!_available) return {};
    final doc = await _wishlistColl.findOne(where.eq('type', 'global'));
    if (doc == null) return {};
    return (doc['ids'] as List).cast<String>().toSet();
  }

  // Orders
  Future<void> insertOrder(m.Order o) async {
    await _ensureOpen();
    if (!_available) return;
    await _ordersColl.update(where.eq('id', o.id), o.toMap(), upsert: true);
  }

  Stream<List<m.Order>> ordersStream() {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      await _ensureOpen();
      if (!_available) return [];
      final list = await _ordersColl
          .find(where.sortBy('createdAt', descending: true))
          .toList();
      return list.map((e) => m.Order.fromMap(e)).toList();
    });
  }

  // Bookings
  Future<void> insertBooking(m.Booking b) async {
    await _ensureOpen();
    if (!_available) return;
    await _bookingsColl.update(where.eq('id', b.id), b.toMap(), upsert: true);
  }

  Future<List<m.Booking>> loadBookings() async {
    await _ensureOpen();
    if (!_available) return [];
    final list = await _bookingsColl.find().toList();
    return list.map((e) => m.Booking.fromMap(e)).toList();
  }

  // Payments
  Future<void> insertPayment(m.PaymentRecord p) async {
    await _ensureOpen();
    if (!_available) return;
    await _paymentsColl.update(where.eq('id', p.id), p.toMap(), upsert: true);
  }

  Future<List<m.PaymentRecord>> loadPayments() async {
    await _ensureOpen();
    if (!_available) return [];
    final list = await _paymentsColl.find().toList();
    return list.map((e) => m.PaymentRecord.fromMap(e)).toList();
  }

  // Feedback
  Future<void> insertFeedback(m.FeedbackEntry fdb) async {
    await _ensureOpen();
    if (!_available) return;
    await _feedbackColl.update(
      where.eq('id', fdb.id),
      fdb.toMap(),
      upsert: true,
    );
  }

  Future<List<m.FeedbackEntry>> loadFeedbacks() async {
    await _ensureOpen();
    if (!_available) return [];
    final list = await _feedbackColl.find().toList();
    return list.map((e) => m.FeedbackEntry.fromMap(e)).toList();
  }
}
