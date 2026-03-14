import 'package:cloud_firestore/cloud_firestore.dart' as f;
import 'package:firebase_core/firebase_core.dart' as fc;
import '../models/item.dart' as m;

class FirebaseStore {
  static final FirebaseStore instance = FirebaseStore._internal();
  FirebaseStore._internal();

  bool _available = false;
  bool get isAvailable => _available;

  Future<void> init() async {
    try {
      await fc.Firebase.initializeApp();
      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  Future<void> insertUser(String id, String name, String email, String password, String role) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('users').doc(id).set({'name': name, 'email': email, 'password': password, 'role': role});
  }

  Future<List<Map<String, Object?>>> loadUsers() async {
    if (!_available) return [];
    final snap = await f.FirebaseFirestore.instance.collection('users').get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<bool> isCatalogEmpty() async {
    if (!_available) return true;
    final p = await f.FirebaseFirestore.instance.collection('products').limit(1).get();
    final s = await f.FirebaseFirestore.instance.collection('spares').limit(1).get();
    final sv = await f.FirebaseFirestore.instance.collection('services').limit(1).get();
    return p.size == 0 && s.size == 0 && sv.size == 0;
  }

  Future<void> insertProduct(m.Product p) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('products').doc(p.id).set({'name': p.name, 'description': p.description, 'price': p.price, 'imageUrl': p.imageUrl, 'inStock': p.inStock});
  }

  Future<void> updateProduct(m.Product p) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('products').doc(p.id).update({'name': p.name, 'description': p.description, 'price': p.price, 'imageUrl': p.imageUrl, 'inStock': p.inStock});
  }

  Future<void> deleteProduct(String id) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  Future<List<m.Product>> loadProducts() async {
    if (!_available) return [];
    final snap = await f.FirebaseFirestore.instance.collection('products').get();
    return snap.docs
        .map((d) {
          final data = d.data();
          return m.Product(id: d.id, name: data['name'], description: data['description'], price: (data['price'] as num).toDouble(), imageUrl: data['imageUrl'], inStock: data['inStock'] as bool? ?? true);
        })
        .toList();
  }

  Future<void> insertSpare(m.SparePart s) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('spares').doc(s.id).set({'name': s.name, 'description': s.description, 'price': s.price, 'imageUrl': s.imageUrl, 'inStock': s.inStock});
  }

  Future<void> updateSpare(m.SparePart s) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('spares').doc(s.id).update({'name': s.name, 'description': s.description, 'price': s.price, 'imageUrl': s.imageUrl, 'inStock': s.inStock});
  }

  Future<void> deleteSpare(String id) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('spares').doc(id).delete();
  }

  Future<List<m.SparePart>> loadSpares() async {
    if (!_available) return [];
    final snap = await f.FirebaseFirestore.instance.collection('spares').get();
    return snap.docs
        .map((d) {
          final data = d.data();
          return m.SparePart(id: d.id, name: data['name'], description: data['description'], price: (data['price'] as num).toDouble(), imageUrl: data['imageUrl'], inStock: data['inStock'] as bool? ?? true);
        })
        .toList();
  }

  Future<void> insertService(m.ServiceType s) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('services').doc(s.id).set({'name': s.name, 'description': s.description, 'price': s.price});
  }

  Future<void> updateService(m.ServiceType s) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('services').doc(s.id).update({'name': s.name, 'description': s.description, 'price': s.price});
  }

  Future<void> deleteService(String id) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('services').doc(id).delete();
  }

  Future<List<m.ServiceType>> loadServices() async {
    if (!_available) return [];
    final snap = await f.FirebaseFirestore.instance.collection('services').get();
    return snap.docs
        .map((d) {
          final data = d.data();
          return m.ServiceType(id: d.id, name: data['name'], description: data['description'], price: (data['price'] as num).toDouble());
        })
        .toList();
  }

  Future<void> setWishlist(Set<String> ids) async {
    if (!_available) return;
    final col = f.FirebaseFirestore.instance.collection('wishlist');
    final batch = f.FirebaseFirestore.instance.batch();
    final snapshot = await col.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    for (final id in ids) {
      batch.set(col.doc(id), {'id': id});
    }
    await batch.commit();
  }

  Future<Set<String>> loadWishlist() async {
    if (!_available) return <String>{};
    final snap = await f.FirebaseFirestore.instance.collection('wishlist').get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<void> insertOrder(m.Order o) async {
    if (!_available) return;
    final orders = f.FirebaseFirestore.instance.collection('orders').doc(o.id);
    await orders.set({'userEmail': o.userEmail, 'createdAt': o.createdAt.millisecondsSinceEpoch, 'total': o.total, 'status': o.status});
    final itemsCol = orders.collection('items');
    final batch = f.FirebaseFirestore.instance.batch();
    for (final it in o.items) {
      final ref = itemsCol.doc();
      batch.set(ref, {'refId': it.refId, 'name': it.name, 'type': it.type, 'price': it.price, 'quantity': it.quantity});
    }
    await batch.commit();
  }

  Future<List<m.Order>> loadOrders() async {
    if (!_available) return [];
    final ordersCol = f.FirebaseFirestore.instance.collection('orders');
    final snap = await ordersCol.get();
    final List<m.Order> result = [];
    for (final d in snap.docs) {
      final data = d.data();
      final itemsSnap = await ordersCol.doc(d.id).collection('items').get();
      final items = itemsSnap.docs
          .map((i) => m.OrderItem(refId: i['refId'], name: i['name'], type: i['type'], price: (i['price'] as num).toDouble(), quantity: i['quantity'] as int))
          .toList();
      result.add(m.Order(id: d.id, userEmail: data['userEmail'], createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int), items: items, total: (data['total'] as num).toDouble(), status: data['status']));
    }
    return result;
  }

  Future<void> insertBooking(m.Booking b) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('bookings').doc(b.id).set({'customerName': b.customerName, 'phone': b.phone, 'address': b.address, 'serviceId': b.service.id, 'serviceName': b.service.name, 'servicePrice': b.service.price, 'createdAt': b.createdAt.millisecondsSinceEpoch});
  }

  Future<List<m.Booking>> loadBookings() async {
    if (!_available) return [];
    final snap = await f.FirebaseFirestore.instance.collection('bookings').get();
    return snap.docs
        .map((d) {
          final data = d.data();
          return m.Booking(id: d.id, customerName: data['customerName'], phone: data['phone'], address: data['address'], service: m.ServiceType(id: data['serviceId'], name: data['serviceName'], description: '', price: (data['servicePrice'] as num).toDouble()), createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int));
        })
        .toList();
  }

  Future<void> insertPayment(m.PaymentRecord p) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('payments').doc(p.id).set({'amount': p.amount, 'date': p.date.millisecondsSinceEpoch, 'method': p.method});
  }

  Future<List<m.PaymentRecord>> loadPayments() async {
    if (!_available) return [];
    final snap = await f.FirebaseFirestore.instance.collection('payments').get();
    return snap.docs
        .map((d) {
          final data = d.data();
          return m.PaymentRecord(id: d.id, amount: (data['amount'] as num).toDouble(), date: DateTime.fromMillisecondsSinceEpoch(data['date'] as int), method: data['method']);
        })
        .toList();
  }

  Future<void> insertFeedback(m.FeedbackEntry fdb) async {
    if (!_available) return;
    await f.FirebaseFirestore.instance.collection('feedbacks').doc(fdb.id).set({
      'userName': fdb.userName,
      'userEmail': fdb.userEmail,
      'message': fdb.message,
      'rating': fdb.rating,
      'createdAt': fdb.createdAt.millisecondsSinceEpoch,
    });
  }

  Future<List<m.FeedbackEntry>> loadFeedbacks() async {
    if (!_available) return [];
    final snap = await f.FirebaseFirestore.instance.collection('feedbacks').get();
    return snap.docs
        .map((d) {
          final data = d.data();
          return m.FeedbackEntry(
            id: d.id,
            userName: data['userName'],
            userEmail: data['userEmail'],
            message: data['message'],
            rating: (data['rating'] as num).toInt(),
            createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
          );
        })
        .toList();
  }
}
