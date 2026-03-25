import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/item.dart';
import 'atlas_store.dart';

/// Global in‑memory state for the AirXpert demo application.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'user' or 'admin'

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal() {
    _loadDemoDataLocally();
  }

  // ===== Authentication =====
  final List<AppUser> _users = [];
  AppUser? currentUser;

  String razorpayKey = 'rzp_test_SRa0tNfozzXKDh';
  String razorpaySecret = 'ajsAiWusXQQhE00je616KSzF';

  List<AppUser> get registeredUsers => List.unmodifiable(_users);

  // ===== State Variables =====
  final List<Product> _products = [];
  final List<SparePart> _spares = [];
  final List<ServiceType> _services = [];
  final List<Order> _orders = [];
  final List<Booking> _bookings = [];
  final List<PaymentRecord> _payments = [];
  final Set<String> _wishlist = {};
  final List<FeedbackEntry> _feedbacks = [];

  // ===== Getters =====
  List<Product> get products => List.unmodifiable(_products);
  List<SparePart> get spares => List.unmodifiable(_spares);
  List<ServiceType> get services => List.unmodifiable(_services);
  List<Order> get orders => List.unmodifiable(_orders);
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<PaymentRecord> get payments => List.unmodifiable(_payments);
  Set<String> get wishlistIds => Set.unmodifiable(_wishlist);
  Set<String> get wishlist => _wishlist; // Added for compatibility with screens
  List<FeedbackEntry> get feedbacks => List.unmodifiable(_feedbacks);

  // ===== Subscriptions =====
  StreamSubscription? _productsSub;
  StreamSubscription? _sparesSub;
  StreamSubscription? _servicesSub;
  StreamSubscription? _ordersSub;

  Future<void> init() async {
    // 1. Load local demo data immediately
    _loadDemoDataLocally();
    notifyListeners();

    await AtlasStore.instance.init();

    // 2. Initial load for users
    print('📥 Loading users from Atlas...');
    final usersRows = await AtlasStore.instance.loadUsers();
    if (usersRows.isNotEmpty) {
      _users.clear();
      for (final r in usersRows) {
        try {
          _users.add(
            AppUser(
              id: (r['id'] ?? r['_id'] ?? 'unknown').toString(),
              name: (r['name'] ?? 'No Name').toString(),
              email: (r['email'] ?? '').toString(),
              password: (r['password'] ?? '').toString(),
              role: (r['role'] ?? 'user').toString(),
            ),
          );
        } catch (e) {
          print('⚠️ Error parsing user row: $e');
        }
      }
      print('✅ Loaded ${_users.length} users from Atlas');
    } else {
      print('ℹ️ No users found in Atlas, using demo users');
      await AtlasStore.instance.insertUser(
        'admin-1',
        'Shop Owner',
        'admin@airxpert.demo',
        'admin123',
        'admin',
      );
      await AtlasStore.instance.insertUser(
        'user-1',
        'Customer',
        'user@airxpert.demo',
        'user1234',
        'user',
      );
    }

    if (_users.isEmpty) {
      _users.addAll([
        const AppUser(
          id: 'admin-1',
          name: 'Shop Owner',
          email: 'admin@airxpert.demo',
          password: 'admin123',
          role: 'admin',
        ),
        const AppUser(
          id: 'user-1',
          name: 'Customer',
          email: 'user@airxpert.demo',
          password: 'user1234',
          role: 'user',
        ),
      ]);
    }

    // 3. Seed remote if empty
    final emptyCatalog = await AtlasStore.instance.isCatalogEmpty();
    if (emptyCatalog) {
      await _seedDemoDataToRemote();
    }

    // 4. Start Real-time listeners with error handling
    _productsSub?.cancel();
    _productsSub = AtlasStore.instance.productsStream().listen(
      (list) {
        _products.clear();
        if (list.isEmpty) {
          _loadDemoProductsLocally();
        } else {
          // Show newest products first (assuming higher ID = newer, or just for consistency)
          _products.addAll(list.reversed);
        }
        _repairMissingImagesLocally();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Atlas products error: $e');
        if (_products.isEmpty) {
          _loadDemoProductsLocally();
          notifyListeners();
        }
      },
    );

    _sparesSub?.cancel();
    _sparesSub = AtlasStore.instance.sparesStream().listen(
      (list) {
        _spares.clear();
        if (list.isEmpty) {
          _loadDemoSparesLocally();
        } else {
          _spares.addAll(list.reversed);
        }
        _repairMissingImagesLocally();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Atlas spares error: $e');
        if (_spares.isEmpty) {
          _loadDemoSparesLocally();
          notifyListeners();
        }
      },
    );

    _servicesSub?.cancel();
    _servicesSub = AtlasStore.instance.servicesStream().listen(
      (list) {
        _services.clear();
        if (list.isEmpty) {
          _loadDemoServicesLocally();
        } else {
          _services.addAll(list.reversed);
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Atlas services error: $e');
        if (_services.isEmpty) {
          _loadDemoServicesLocally();
          notifyListeners();
        }
      },
    );

    _ordersSub?.cancel();
    _ordersSub = AtlasStore.instance.ordersStream().listen((list) {
      _orders.clear();
      _orders.addAll(list);
      notifyListeners();
    });

    // One-time loads for remaining
    _bookings.clear();
    _bookings.addAll(await AtlasStore.instance.loadBookings());
    _payments.clear();
    _payments.addAll(await AtlasStore.instance.loadPayments());
    _wishlist.clear();
    _wishlist.addAll(await AtlasStore.instance.loadWishlist());
    _feedbacks.clear();
    _feedbacks.addAll(await AtlasStore.instance.loadFeedbacks());

    notifyListeners();
  }

  void _loadDemoDataLocally() {
    _products.clear();
    _spares.clear();
    _services.clear();
    _loadDemoProductsLocally();
    _loadDemoSparesLocally();
    _loadDemoServicesLocally();
  }

  void _loadDemoProductsLocally() {
    _products.clear();
    _products.addAll([
      const Product(
        id: 'p1',
        name: 'Daikin 1.5 Ton Inverter AC',
        nameTa: 'டைகின் 1.5 டன் இன்வெர்ட்டர் ஏசி',
        description:
            'High‑efficiency split AC with fast cooling and triple display.',
        descriptionTa:
            'வேகமான குளிர்ச்சியுடன் கூடிய உயர் செயல்திறன் கொண்ட ஸ்பிளிட் ஏசி.',
        price: 42999,
        imageUrl:
            'https://m.media-amazon.com/images/I/51H96-w-pSL._SL1500_.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p2',
        name: 'Blue Star 2 Ton Cassette AC',
        nameTa: 'புளூ ஸ்டார் 2 டன் கேசட் ஏசி',
        description:
            'Ideal for commercial spaces and showrooms with 4-way airflow.',
        descriptionTa: 'வணிக இடங்கள் மற்றும் ஷோரூம்களுக்கு ஏற்றது.',
        price: 65999,
        imageUrl:
            'https://m.media-amazon.com/images/I/61rU1X7+XKL._SL1500_.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p3',
        name: 'Voltas 1 Ton Window AC',
        nameTa: 'வோல்டாஸ் 1 டன் விண்டோ ஏசி',
        description: 'Compact cooling for small rooms, easy installation.',
        descriptionTa: 'சிறிய அறைகளுக்கு ஏற்ற சிறிய குளிரூட்டி.',
        price: 27999,
        imageUrl:
            'https://m.media-amazon.com/images/I/61S-rO-0bSL._SL1500_.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p4',
        name: 'LG 1.5 Ton AI DUAL Inverter Split AC',
        nameTa: 'எல்ஜி 1.5 டன் ஏஐ டூயல் இன்வெர்ட்டர் ஸ்பிளிட் ஏசி',
        description:
            'Standard cooling for medium rooms with smart connectivity.',
        descriptionTa: 'நடுத்தர அறைகளுக்கு ஏற்ற தரமான குளிர்ச்சி.',
        price: 35999,
        imageUrl:
            'https://m.media-amazon.com/images/I/51fX6y6m6rL._SL1500_.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p5',
        name: 'Samsung 1 Ton Portable AC',
        nameTa: 'சாம்சங் 1 டன் போர்ட்டபிள் ஏசி',
        description: 'Easy to move and install anywhere with powerful airflow.',
        descriptionTa: 'எங்கும் எளிதாக நகர்த்த மற்றும் நிறுவக்கூடியது.',
        price: 31999,
        imageUrl:
            'https://m.media-amazon.com/images/I/61T2iW+5Z5L._SL1500_.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p6',
        name: 'Carrier 2 Ton Inverter Split AC',
        nameTa: 'கேரியர் 2 டன் இன்வெர்ட்டர் ஸ்பிளிட் ஏசி',
        description: 'Latest Wi-Fi enabled cooling for large spaces.',
        descriptionTa: 'பெரிய இடங்களுக்கான நவீன வைஃபை கன்ட்ரோல் குளிரூட்டி.',
        price: 55999,
        imageUrl:
            'https://m.media-amazon.com/images/I/51C+S5Z5KKL._SL1500_.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p7',
        name: 'Lloyd 1.5 Ton Window AC',
        nameTa: 'லாயிட் 1.5 டன் விண்டோ ஏசி',
        description:
            'Energy-saving 5-star AC with fast cooling and LED display.',
        descriptionTa: 'மின்சாரம் சேமிக்கும் 5-ஸ்டார் ஏசி.',
        price: 34500,
        imageUrl:
            'https://m.media-amazon.com/images/I/61rU1X7+XKL._SL1500_.jpg',
        inStock: true,
      ),
    ]);
  }

  void _loadDemoSparesLocally() {
    _spares.clear();
    _spares.addAll([
      const SparePart(
        id: 's1',
        name: 'AC Compressor',
        nameTa: 'ஏசி கம்ப்ரசர்',
        description: 'Original rotary compressor for 1.5 Ton units.',
        descriptionTa: '1.5 டன் யூனிட்டுகளுக்கான அசல் ரோட்டரி கம்ப்ரசர்.',
        price: 7800,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's2',
        name: 'Outdoor Fan Motor',
        nameTa: 'வெளிப்புற விசிறி மோட்டார்',
        description: 'Durable fan motor for split AC outdoor units.',
        descriptionTa:
            'ஸ்பிளிட் ஏசி வெளிப்புற யூனிட்டுகளுக்கான நீடித்த விசிறி மோட்டார்.',
        price: 2100,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's3',
        name: 'AC PCB Board',
        nameTa: 'ஏசி பிசிபி போர்டு',
        description: 'Universal control board for split AC.',
        descriptionTa: 'ஸ்பிளிட் ஏசிக்கான யுனிவர்சல் கட்டுப்பாட்டு வாரியம்.',
        price: 4500,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's4',
        name: 'Copper Coil Set',
        nameTa: 'காப்பர் காயில் செட்',
        description: 'High-quality copper piping for AC.',
        descriptionTa: 'ஏசிக்கான உயர்தர காப்பர் பைப்பிங்.',
        price: 3200,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's5',
        name: 'Remote Controller',
        nameTa: 'ரிமோட் கண்ட்ரோலர்',
        description: 'Compatible with all major AC brands.',
        descriptionTa: 'அனைத்து முக்கிய ஏசி பிராண்டுகளுக்கும் ஏற்றது.',
        price: 850,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
    ]);
  }

  void _loadDemoServicesLocally() {
    _services.addAll([
      const ServiceType(
        id: 'svc1',
        name: 'AC General Service',
        nameTa: 'ஏசி பொது சேவை',
        description: 'Complete cleaning, filters, and performance check.',
        descriptionTa:
            'முழுமையான சுத்தம், வடிகட்டிகள் மற்றும் செயல்திறன் சரிபார்ப்பு.',
        price: 799,
      ),
      const ServiceType(
        id: 'svc2',
        name: 'AC Installation',
        nameTa: 'ஏசி நிறுவல்',
        description: 'Standard split AC installation with testing.',
        descriptionTa: 'சோதனையுடன் கூடிய நிலையான ஸ்பிளிட் ஏசி நிறுவல்.',
        price: 1499,
      ),
    ]);
  }

  void _repairMissingImagesLocally() {
    const acUrl =
        'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg';
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].imageUrl.trim().isEmpty) {
        _products[i] = Product(
          id: _products[i].id,
          name: _products[i].name,
          nameTa: _products[i].nameTa,
          description: _products[i].description,
          descriptionTa: _products[i].descriptionTa,
          price: _products[i].price,
          imageUrl: acUrl,
          inStock: _products[i].inStock,
        );
      }
    }
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _sparesSub?.cancel();
    _servicesSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> _seedDemoDataToRemote() async {
    final demoProducts = [
      const Product(
        id: 'p1',
        name: '1.5 Ton Inverter AC',
        nameTa: '1.5 டன் இன்வெர்ட்டர் ஏசி',
        description: 'High‑efficiency split AC with fast cooling.',
        descriptionTa:
            'வேகமான குளிர்ச்சியுடன் கூடிய உயர் செயல்திறன் கொண்ட ஸ்பிளிட் ஏசி.',
        price: 38999,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p2',
        name: '2 Ton Cassette AC',
        nameTa: '2 டன் கேசட் ஏசி',
        description: 'Ideal for commercial spaces and showrooms.',
        descriptionTa: 'வணிக இடங்கள் மற்றும் ஷோரூம்களுக்கு ஏற்றது.',
        price: 62999,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/6/66/Ceiling_cassette_type_air_conditioner.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p3',
        name: '1 Ton Window AC',
        nameTa: '1 டன் விண்டோ ஏசி',
        description: 'Compact cooling for small rooms.',
        descriptionTa: 'சிறிய அறைகளுக்கு ஏற்ற சிறிய குளிரூட்டி.',
        price: 25999,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/e6/Window_air_conditioner.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p4',
        name: '1.5 Ton Split AC',
        nameTa: '1.5 டன் ஸ்பிளிட் ஏசி',
        description: 'Standard cooling for medium rooms.',
        descriptionTa: 'நடுத்தர அறைகளுக்கு ஏற்ற தரமான குளிர்ச்சி.',
        price: 32999,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/31/Split_type_air_conditioner_outdoor_unit.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p5',
        name: 'Portable AC 1 Ton',
        nameTa: 'போர்ட்டபிள் ஏசி 1 டன்',
        description: 'Easy to move and install anywhere.',
        descriptionTa: 'எங்கும் எளிதாக நகர்த்த மற்றும் நிறுவக்கூடியது.',
        price: 28999,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/1a/Portable_air_conditioner.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p6',
        name: 'Premium 2 Ton Inverter Split AC',
        nameTa: 'பிரீமியம் 2 டன் இன்வெர்ட்டர் ஸ்பிளிட் ஏசி',
        description: 'Latest Wi-Fi enabled cooling for large spaces.',
        descriptionTa: 'பெரிய இடங்களுக்கான நவீன வைஃபை கன்ட்ரோல் குளிரூட்டி.',
        price: 52999,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/31/Split_type_air_conditioner_outdoor_unit.jpg',
        inStock: true,
      ),
      const Product(
        id: 'p7',
        name: 'Smart 1.5 Ton Window AC',
        nameTa: 'ஸ்மார்ட் 1.5 டன் விண்டோ ஏசி',
        description: 'Energy-saving 5-star AC with fast cooling.',
        descriptionTa: 'மின்சாரம் சேமிக்கும் 5-ஸ்டார் ஏசி.',
        price: 34500,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/e/e6/Window_air_conditioner.jpg',
        inStock: true,
      ),
    ];
    for (final p in demoProducts) {
      await AtlasStore.instance.insertProduct(p);
    }

    final demoSpares = [
      const SparePart(
        id: 's1',
        name: 'AC Compressor',
        nameTa: 'ஏசி கம்ப்ரசர்',
        description: 'Original rotary compressor for 1.5 Ton units.',
        descriptionTa: '1.5 டன் யூனிட்டுகளுக்கான அசல் ரோட்டரி கம்ப்ரசர்.',
        price: 7800,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's2',
        name: 'Outdoor Fan Motor',
        nameTa: 'வெளிப்புற விசிறி மோட்டார்',
        description: 'Durable fan motor for split AC outdoor units.',
        descriptionTa:
            'ஸ்பிளிட் ஏசி வெளிப்புற யூனிட்டுகளுக்கான நீடித்த விசிறி மோட்டார்.',
        price: 2100,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's3',
        name: 'AC PCB Board',
        nameTa: 'ஏசி பிசிபி போர்டு',
        description: 'Universal control board for split AC.',
        descriptionTa: 'ஸ்பிளிட் ஏசிக்கான யுனிவர்சல் கட்டுப்பாட்டு வாரியம்.',
        price: 4500,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's4',
        name: 'Copper Coil Set',
        nameTa: 'காப்பர் காயில் செட்',
        description: 'High-quality copper piping for AC.',
        descriptionTa: 'ஏசிக்கான உயர்தர காப்பர் பைப்பிங்.',
        price: 3200,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
      const SparePart(
        id: 's5',
        name: 'Remote Controller',
        nameTa: 'ரிமோட் கண்ட்ரோலர்',
        description: 'Compatible with all major AC brands.',
        descriptionTa: 'அனைத்து முக்கிய ஏசி பிராண்டுகளுக்கும் ஏற்றது.',
        price: 850,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/96/Split_air_conditioner_indoor_unit.jpg',
        inStock: true,
      ),
    ];
    for (final s in demoSpares) {
      await AtlasStore.instance.insertSpare(s);
    }

    final demoServices = [
      const ServiceType(
        id: 'svc1',
        name: 'AC General Service',
        nameTa: 'ஏசி பொது சேவை',
        description: 'Complete cleaning, filters, and performance check.',
        descriptionTa:
            'முழுமையான சுத்தம், வடிகட்டிகள் மற்றும் செயல்திறன் சரிபார்ப்பு.',
        price: 799,
      ),
      const ServiceType(
        id: 'svc2',
        name: 'AC Installation',
        nameTa: 'ஏசி நிறுவல்',
        description: 'Standard split AC installation with testing.',
        descriptionTa: 'சோதனையுடன் கூடிய நிலையான ஸ்பிளிட் ஏசி நிறுவல்.',
        price: 1499,
      ),
    ];
    for (final s in demoServices) {
      await AtlasStore.instance.insertService(s);
    }
  }

  void migrateImageUrlsIfNeeded() {
    const acUrl =
        'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg';
    bool needsUpdate = _products.any(
      (p) => p.imageUrl.contains('images.pexels.com'),
    );
    if (needsUpdate) {
      for (final p in List<Product>.from(_products)) {
        updateProduct(
          Product(
            id: p.id,
            name: p.name,
            nameTa: p.nameTa,
            description: p.description,
            descriptionTa: p.descriptionTa,
            price: p.price,
            imageUrl: acUrl,
          ),
        );
      }
    }
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) return 'User already exists';
    if (role != 'user' && role != 'admin') return 'Invalid role';

    final u = AppUser(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      password: password,
      role: role,
    );

    _users.add(u);
    notifyListeners();

    final success = await AtlasStore.instance.insertUser(
      u.id,
      u.name,
      u.email,
      u.password,
      u.role,
    );
    if (!success) {
      // If DB fails, we still keep it in local memory for this session,
      // but warn the user or log it.
      print('⚠️ User created locally but failed to sync to Atlas.');
    }

    return null;
  }

  String? login({required String email, required String password}) {
    final user = _users.where(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase() &&
          u.password == password,
    );
    if (user.isEmpty) {
      return 'Invalid email or password';
    }
    currentUser = user.first;
    customerName = currentUser?.name ?? '';
    phoneNumber = '';
    address = '';
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    clearCart();
    clearBill();
    notifyListeners();
  }

  bool get isAdmin => currentUser?.role == 'admin';

  String generateBillNumber() {
    return 'B${DateTime.now().millisecondsSinceEpoch}';
  }

  // ===== Catalog (Admin CRUD) =====
  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    notifyListeners();
    await AtlasStore.instance.insertProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
      notifyListeners();
    }
    await AtlasStore.instance.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    await AtlasStore.instance.deleteProduct(id);
  }

  Future<void> addSpare(SparePart spare) async {
    _spares.insert(0, spare);
    notifyListeners();
    await AtlasStore.instance.insertSpare(spare);
  }

  Future<void> updateSpare(SparePart spare) async {
    final idx = _spares.indexWhere((s) => s.id == spare.id);
    if (idx != -1) {
      _spares[idx] = spare;
      notifyListeners();
    }
    await AtlasStore.instance.updateSpare(spare);
  }

  Future<void> deleteSpare(String id) async {
    _spares.removeWhere((s) => s.id == id);
    notifyListeners();
    await AtlasStore.instance.deleteSpare(id);
  }

  Future<void> addService(ServiceType service) async {
    _services.insert(0, service);
    notifyListeners();
    await AtlasStore.instance.insertService(service);
  }

  Future<void> updateService(ServiceType service) async {
    final idx = _services.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      _services[idx] = service;
      notifyListeners();
    }
    await AtlasStore.instance.updateService(service);
  }

  Future<void> deleteService(String id) async {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
    await AtlasStore.instance.deleteService(id);
  }

  // ===== Wishlist =====
  Future<void> toggleWishlist(String id) async {
    if (_wishlist.contains(id)) {
      _wishlist.remove(id);
    } else {
      _wishlist.add(id);
    }
    notifyListeners();
    await AtlasStore.instance.setWishlist(_wishlist);
  }

  bool isWishlisted(String id) => _wishlist.contains(id);

  // ===== Cart / Billing =====
  String customerName = '';
  String phoneNumber = '';
  String address = '';

  final List<CartItem> _cart = [];
  final List<BillItem> billItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cart);
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  void setCustomerDetails({
    required String name,
    required String phone,
    required String addr,
  }) {
    customerName = name;
    phoneNumber = phone;
    address = addr;
    notifyListeners();
  }

  void addToCart(CartItem item) {
    final idx = _cart.indexWhere((c) => c.id == item.id && c.type == item.type);
    if (idx == -1) {
      _cart.add(item);
    } else {
      _cart[idx] = _cart[idx].copyWith(
        quantity: _cart[idx].quantity + item.quantity,
      );
    }
    notifyListeners();
  }

  void removeFromCart(String id, String type) {
    _cart.removeWhere((c) => c.id == id && c.type == type);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void addBillItem(BillItem item) {
    billItems.add(item);
    notifyListeners();
  }

  void syncBillFromCart() {
    billItems
      ..clear()
      ..addAll(
        _cart.map(
          (c) => BillItem(
            name: c.name,
            nameTa: c.nameTa,
            price: c.price * c.quantity,
            type: c.type,
          ),
        ),
      );
    notifyListeners();
  }

  void clearBill() {
    billItems.clear();
    customerName = '';
    phoneNumber = '';
    address = '';
    notifyListeners();
  }

  double get cartTotal =>
      _cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get totalAmount =>
      billItems.fold(0.0, (sum, item) => sum + item.price);

  // ===== Bookings & Payments =====
  Future<void> addBooking({
    required String customerName,
    required String phone,
    required String address,
    required ServiceType service,
  }) async {
    final b = Booking(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      phone: phone,
      address: address,
      service: service,
      createdAt: DateTime.now(),
    );
    _bookings.add(b);
    notifyListeners();
    await AtlasStore.instance.insertBooking(b);
  }

  Future<void> addPayment(double amount, String method) async {
    final p = PaymentRecord(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      method: method,
    );
    _payments.add(p);
    notifyListeners();
    await AtlasStore.instance.insertPayment(p);
  }

  Future<void> addFeedback({
    required String message,
    required int rating,
  }) async {
    final u = currentUser;
    final f = FeedbackEntry(
      id: 'fb-${DateTime.now().millisecondsSinceEpoch}',
      userName: u?.name ?? 'Guest',
      userEmail: u?.email ?? 'guest',
      message: message,
      rating: rating,
      createdAt: DateTime.now(),
    );
    _feedbacks.add(f);
    notifyListeners();
    await AtlasStore.instance.insertFeedback(f);
  }

  Future<Order> placeOrderFromCart({String status = 'placed'}) async {
    final items = _cart
        .map(
          (c) => OrderItem(
            refId: c.id,
            name: c.name,
            nameTa: c.nameTa,
            type: c.type,
            price: c.price * c.quantity,
            quantity: c.quantity,
          ),
        )
        .toList();
    final order = Order(
      id: 'O${DateTime.now().millisecondsSinceEpoch}',
      userEmail: currentUser?.email ?? 'guest',
      createdAt: DateTime.now(),
      items: items,
      total: cartTotal,
      status: status,
    );
    _orders.add(order);
    notifyListeners();
    await AtlasStore.instance.insertOrder(order);
    clearCart();
    return order;
  }
}
