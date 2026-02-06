import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/service_booking_screen.dart';
import 'screens/products_screen.dart';
import 'screens/spares_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/order_summary_screen.dart';
import 'screens/pay_screen.dart';
import 'screens/orders_screen.dart';
import 'state/app_state.dart';

// Remove default overscroll glow across the app
class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

void main() {
  runApp(const AirXpertRoot());
}

/// Top‑level state holder for theme + language.
class AirXpertRoot extends StatefulWidget {
  const AirXpertRoot({super.key});

  @override
  State<AirXpertRoot> createState() => _AirXpertRootState();
}

class _AirXpertRootState extends State<AirXpertRoot> {
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en'; // 'en' or 'ta'

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setLanguage(String code) {
    setState(() {
      _languageCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLanguage(
      languageCode: _languageCode,
      setLanguage: _setLanguage,
      toggleTheme: _toggleTheme,
      child: AirXpertApp(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Simple inherited widget to expose the active language and theme toggle.
class AppLanguage extends InheritedWidget {
  final String languageCode;
  final void Function(String code) setLanguage;
  final VoidCallback toggleTheme;

  const AppLanguage({
    super.key,
    required this.languageCode,
    required this.setLanguage,
    required this.toggleTheme,
    required super.child,
  });

  static AppLanguage of(BuildContext context) {
    final AppLanguage? result =
        context.dependOnInheritedWidgetOfExactType<AppLanguage>();
    assert(result != null, 'No AppLanguage found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant AppLanguage oldWidget) =>
      languageCode != oldWidget.languageCode;
}

class AirXpertApp extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const AirXpertApp({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Custom color palette
    const primaryColor = Color(0xFF6FA8A6); // Teal
    const darkBg1 = Color(0xFF2F3E46); // Dark blue-grey
    const darkBg2 = Color(0xFF22333B); // Darker blue-grey
    const greyMedium = Color(0xFF8A9A9E); // Medium grey
    const greyLight = Color(0xFFDDE3E6); // Light grey
    const bgLight = Color(0xFFF7F9F8); // Off-white
    const white = Color(0xFFFFFFFF); // White

    final colorSchemeLight = ColorScheme.light(
      primary: primaryColor,
      surface: white,
      surfaceContainer: bgLight,
      onPrimary: white,
      onSurface: darkBg2,
      onSurfaceVariant: greyMedium,
    );

    final colorSchemeDark = ColorScheme.dark(
      primary: primaryColor,
      surface: darkBg1,
      surfaceContainer: darkBg2,
      onPrimary: white,
      onSurface: greyLight,
      onSurfaceVariant: greyMedium,
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeLight,
      scaffoldBackgroundColor: bgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkBg2,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkBg2,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeDark,
      scaffoldBackgroundColor: darkBg2,
      cardColor: darkBg1,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg1,
        foregroundColor: greyLight,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: greyLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkBg1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: darkBg1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );

    return MaterialApp(
      title: 'AirXpert',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoGlowScrollBehavior(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/user': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/service': (context) => const ServiceBookingScreen(),
        '/products': (context) => const ProductsScreen(),
        '/spares': (context) => const SparesScreen(),
        '/billing': (context) => const BillingScreen(),
        '/contact': (context) => const ContactScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/order-summary': (context) => const OrderSummaryScreen(),
        '/pay': (context) => const PayScreen(),
        '/orders': (context) => const OrdersScreen(),
      },
    );
  }
}
