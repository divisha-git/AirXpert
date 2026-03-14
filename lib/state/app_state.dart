import 'dart:async';
import '../models/item.dart';
import 'firebase_store.dart';

/// Global in‑memory state for the AirXpert demo application.
///
/// This is intentionally simple and non‑persistent so that the
/// focus stays on UX, flows, and screen design. In production
/// this would be backed by secure auth, a database, and APIs.

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password; // in‑memory only – DO NOT use like this in real apps
  final String role; // 'user' or 'admin'

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

class AppState {
  static final AppState instance = AppState._internal();
  AppState._internal();

  // ===== Authentication =====
  final List<AppUser> _users = [];
  AppUser? currentUser;

  List<AppUser> get registeredUsers => List.unmodifiable(_users);

  Future<void> init() async {
    await FirebaseStore.instance.init();
    final usersRows = await FirebaseStore.instance.loadUsers();
    if (usersRows.isEmpty) {
      await FirebaseStore.instance.insertUser('admin-1', 'Shop Owner', 'admin@airxpert.demo', 'admin123', 'admin');
      await FirebaseStore.instance.insertUser('user-1', 'Customer', 'user@airxpert.demo', 'user1234', 'user');
    }
    for (final r in await FirebaseStore.instance.loadUsers()) {
      _users.add(AppUser(id: r['id'] as String, name: r['name'] as String, email: r['email'] as String, password: r['password'] as String, role: r['role'] as String));
    }
    final emptyCatalog = await FirebaseStore.instance.isCatalogEmpty();
    if (emptyCatalog) {
      await _seedDemoDataToRemote();
    }
    _products
      ..clear()
      ..addAll(await FirebaseStore.instance.loadProducts());
    _spares
      ..clear()
      ..addAll(await FirebaseStore.instance.loadSpares());
    _services
      ..clear()
      ..addAll(await FirebaseStore.instance.loadServices());
    await _repairMissingImages();
    _orders
      ..clear()
      ..addAll(await FirebaseStore.instance.loadOrders());
    _bookings
      ..clear()
      ..addAll(await FirebaseStore.instance.loadBookings());
    _payments
      ..clear()
      ..addAll(await FirebaseStore.instance.loadPayments());
    _wishlist
      ..clear()
      ..addAll(await FirebaseStore.instance.loadWishlist());
    _feedbacks
      ..clear()
      ..addAll(await FirebaseStore.instance.loadFeedbacks());
    if (_products.isEmpty && _spares.isEmpty && _services.isEmpty) {
      final demoProducts = [
        const Product(
          id: 'p1',
          name: '1.5 Ton Inverter AC',
          description: 'High‑efficiency split AC with fast cooling.',
          price: 38999,
          imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
          inStock: true,
        ),
        const Product(
          id: 'p2',
          name: '2 Ton Cassette AC',
          description: 'Ideal for commercial spaces and showrooms.',
          price: 62999,
          imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
          inStock: true,
        ),
        const Product(
          id: 'p3',
          name: '1 Ton Window AC',
          description: 'Compact cooling for small rooms.',
          price: 25999,
          imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
          inStock: true,
        ),
      ];
      final demoSpares = [
        const SparePart(
          id: 's1',
          name: 'AC Compressor',
          description: 'Original rotary compressor for 1.5 Ton units.',
          price: 7800,
          imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
          inStock: true,
        ),
        const SparePart(
          id: 's2',
          name: 'Outdoor Fan Motor',
          description: 'Durable fan motor for split AC outdoor units.',
          price: 2100,
          imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
          inStock: true,
        ),
      ];
      final demoServices = [
        const ServiceType(
          id: 'svc1',
          name: 'AC General Service',
          description: 'Complete cleaning, filters, and performance check.',
          price: 799,
        ),
        const ServiceType(
          id: 'svc2',
          name: 'AC Installation',
          description: 'Standard split AC installation with testing.',
          price: 1499,
        ),
      ];
      _products.addAll(demoProducts);
      _spares.addAll(demoSpares);
      _services.addAll(demoServices);
    }
  }

  Future<void> _seedDemoDataToRemote() async {
    // One admin + one user to make the app easy to explore.
    // Demo catalog data to DB only
    final demoProducts = [
      const Product(
        id: 'p1',
        name: '1.5 Ton Inverter AC',
        description: 'High‑efficiency split AC with fast cooling.',
        price: 38999,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p2',
        name: '2 Ton Cassette AC',
        description: 'Ideal for commercial spaces and showrooms.',
        price: 62999,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p3',
        name: '1 Ton Window AC',
        description: 'Compact cooling for small rooms.',
        price: 25999,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p4',
        name: '1.5 Ton Split AC (5 Star)',
        description: 'Energy efficient with copper condenser.',
        price: 44999,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p5',
        name: 'Portable AC 1 Ton',
        description: 'Move it anywhere; instant cooling.',
        price: 29999,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p6',
        name: 'VRF Indoor Unit',
        description: 'For large installations and offices.',
        price: 89999,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
    ];
    for (final p in demoProducts) {
      await FirebaseStore.instance.insertProduct(p);
    }

    final demoSpares = [
      const SparePart(
        id: 's1',
        name: 'AC Compressor',
        description: 'Original rotary compressor for 1.5 Ton units.',
        price: 7800,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's2',
        name: 'Outdoor Fan Motor',
        description: 'Durable fan motor for split AC outdoor units.',
        price: 2100,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's3',
        name: 'PCB Board',
        description: 'Original control board for split AC.',
        price: 5200,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's4',
        name: 'Copper Coil Set',
        description: 'High-quality copper piping kit.',
        price: 3400,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's5',
        name: 'Remote Controller',
        description: 'Universal AC remote with display.',
        price: 650,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's6',
        name: 'Air Filter Set',
        description: 'Washable filters for split AC.',
        price: 499,
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
        inStock: true,
      ),
    ];
    for (final s in demoSpares) {
      await FirebaseStore.instance.insertSpare(s);
    }

    final demoServices = [
      const ServiceType(
        id: 'svc1',
        name: 'AC General Service',
        description: 'Complete cleaning, filters, and performance check.',
        price: 799,
      ),
      const ServiceType(
        id: 'svc2',
        name: 'AC Installation',
        description: 'Standard split AC installation with testing.',
        price: 1499,
      ),
      const ServiceType(
        id: 'svc3',
        name: 'Gas Refill',
        description: 'Leak test and refilling with recommended gas.',
        price: 2299,
      ),
    ];
    for (final s in demoServices) {
      await FirebaseStore.instance.insertService(s);
    }
  }

  Future<void> _repairMissingImages() async {
    const acUrl = 'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg';
    for (final p in List<Product>.from(_products)) {
      if (p.imageUrl.trim().isEmpty) {
        updateProduct(Product(
          id: p.id,
          name: p.name,
          description: p.description,
          price: p.price,
          imageUrl: acUrl,
          inStock: p.inStock,
        ));
      }
    }
    for (final s in List<SparePart>.from(_spares)) {
      if (s.imageUrl.trim().isEmpty) {
        updateSpare(SparePart(
          id: s.id,
          name: s.name,
          description: s.description,
          price: s.price,
          imageUrl: acUrl,
          inStock: s.inStock,
        ));
      }
    }
  }

  void migrateImageUrlsIfNeeded() {
    const acUrl =
        'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg';
    bool needsUpdate =
        _products.any((p) => p.imageUrl.contains('images.pexels.com'));
    if (needsUpdate) {
      for (final p in List<Product>.from(_products)) {
        updateProduct(Product(
          id: p.id,
          name: p.name,
          description: p.description,
          price: p.price,
          imageUrl: acUrl,
        ));
      }
    }
  }

  String? signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    final exists = _users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return 'Email already registered';
    if (role != 'user' && role != 'admin') return 'Invalid role';
    final u = AppUser(
      id: 'u-${_users.length + 1}',
      name: name.trim(),
      email: email.trim(),
      password: password,
      role: role,
    );
    _users.add(u);
    unawaited(FirebaseStore.instance.insertUser(u.id, u.name, u.email, u.password, u.role));
    return null; // success
  }

  String? login({required String email, required String password}) {
    final user = _users.where(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
    );
    if (user.isEmpty) {
      return 'Invalid email or password';
    }
    currentUser = user.first;
    // Auto-populate customer details from signup
    customerName = currentUser?.name ?? '';
    phoneNumber = '';
    address = '';
    return null;
  }

  void logout() {
    currentUser = null;
    clearCart();
    clearBill();
  }

  bool get isAdmin => currentUser?.role == 'admin';

  // ===== Catalog (Admin CRUD) =====

  final List<Product> _products = [];
  final List<SparePart> _spares = [];
  final List<ServiceType> _services = [];

  List<Product> get products => List.unmodifiable(_products);
  List<SparePart> get spares => List.unmodifiable(_spares);
  List<ServiceType> get services => List.unmodifiable(_services);

  void addProduct(Product product) {
    _products.add(product);
    unawaited(FirebaseStore.instance.insertProduct(product));
  }
  void updateProduct(Product product) {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) _products[idx] = product;
    unawaited(FirebaseStore.instance.updateProduct(product));
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    unawaited(FirebaseStore.instance.deleteProduct(id));
  }

  void addSpare(SparePart spare) {
    _spares.add(spare);
    unawaited(FirebaseStore.instance.insertSpare(spare));
  }
  void updateSpare(SparePart spare) {
    final idx = _spares.indexWhere((s) => s.id == spare.id);
    if (idx != -1) _spares[idx] = spare;
    unawaited(FirebaseStore.instance.updateSpare(spare));
  }

  void deleteSpare(String id) {
    _spares.removeWhere((s) => s.id == id);
    unawaited(FirebaseStore.instance.deleteSpare(id));
  }

  void addService(ServiceType service) {
    _services.add(service);
    unawaited(FirebaseStore.instance.insertService(service));
  }
  void updateService(ServiceType service) {
    final idx = _services.indexWhere((s) => s.id == service.id);
    if (idx != -1) _services[idx] = service;
    unawaited(FirebaseStore.instance.updateService(service));
  }

  void deleteService(String id) {
    _services.removeWhere((s) => s.id == id);
    unawaited(FirebaseStore.instance.deleteService(id));
  }

  // ===== Wishlist =====
  final Set<String> _wishlist = <String>{}; // product/spare ids

  Set<String> get wishlist => _wishlist;

  void toggleWishlist(String id) {
    if (_wishlist.contains(id)) {
      _wishlist.remove(id);
    } else {
      _wishlist.add(id);
    }
    unawaited(FirebaseStore.instance.setWishlist(_wishlist));
  }

  bool isWishlisted(String id) => _wishlist.contains(id);

  // ===== Cart / Billing =====

  String customerName = '';
  String phoneNumber = '';
  String address = '';

  final List<CartItem> _cart = [];
  final List<BillItem> billItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cart);

  void setCustomerDetails({
    required String name,
    required String phone,
    required String addr,
  }) {
    customerName = name;
    phoneNumber = phone;
    address = addr;
  }

  void addToCart(CartItem item) {
    final idx = _cart.indexWhere((c) => c.id == item.id && c.type == item.type);
    if (idx == -1) {
      _cart.add(item);
    } else {
      _cart[idx] = _cart[idx].copyWith(quantity: _cart[idx].quantity + item.quantity);
    }
  }

  void removeFromCart(String id, String type) {
    _cart.removeWhere((c) => c.id == id && c.type == type);
  }

  void clearCart() {
    _cart.clear();
  }

  void addBillItem(BillItem item) {
    billItems.add(item);
  }

  void syncBillFromCart() {
    billItems
      ..clear()
      ..addAll(
        _cart.map(
          (c) => BillItem(
            name: c.name,
            price: c.price * c.quantity,
            type: c.type,
          ),
        ),
      );
  }

  void clearBill() {
    billItems.clear();
    customerName = '';
    phoneNumber = '';
    address = '';
  }

  double get cartTotal =>
      _cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get totalAmount =>
      billItems.fold(0.0, (sum, item) => sum + item.price);

  String generateBillNumber() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return 'AX$millis';
  }

  // ===== Bookings & Payments (history) =====

  final List<Booking> _bookings = [];
  final List<PaymentRecord> _payments = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<PaymentRecord> get payments => List.unmodifiable(_payments);

  void addBooking({
    required String customerName,
    required String phone,
    required String address,
    required ServiceType service,
  }) {
    final b = Booking(
      id: 'b-${_bookings.length + 1}',
      customerName: customerName,
      phone: phone,
      address: address,
      service: service,
      createdAt: DateTime.now(),
    );
    _bookings.add(b);
    unawaited(FirebaseStore.instance.insertBooking(b));
  }

  void addPayment(double amount, String method) {
    final p = PaymentRecord(
      id: 'pay-${_payments.length + 1}',
      amount: amount,
      date: DateTime.now(),
      method: method,
    );
    _payments.add(p);
    unawaited(FirebaseStore.instance.insertPayment(p));
  }

  // ===== Feedback =====
  final List<FeedbackEntry> _feedbacks = [];
  List<FeedbackEntry> get feedbacks => List.unmodifiable(_feedbacks);
  void addFeedback({required String message, required int rating}) {
    final u = currentUser;
    final f = FeedbackEntry(
      id: 'fb-${_feedbacks.length + 1}',
      userName: u?.name ?? 'Guest',
      userEmail: u?.email ?? 'guest',
      message: message,
      rating: rating,
      createdAt: DateTime.now(),
    );
    _feedbacks.add(f);
    unawaited(FirebaseStore.instance.insertFeedback(f));
  }

  // ===== Orders (in-memory) =====
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  Order placeOrderFromCart({String status = 'placed'}) {
    final items = _cart
        .map((c) => OrderItem(
              refId: c.id,
              name: c.name,
              type: c.type,
              price: c.price * c.quantity,
              quantity: c.quantity,
            ))
        .toList();
    final total = cartTotal;
    final order = Order(
      id: 'O${DateTime.now().millisecondsSinceEpoch}',
      userEmail: currentUser?.email ?? 'guest',
      createdAt: DateTime.now(),
      items: items,
      total: total,
      status: status,
    );
    _orders.add(order);
    unawaited(FirebaseStore.instance.insertOrder(order));
    clearCart();
    return order;
  }

  List<Order> userOrders(String email) =>
      _orders.where((o) => o.userEmail.toLowerCase() == email.toLowerCase()).toList();
}
