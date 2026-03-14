import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/service_booking_screen.dart';
import 'screens/products_screen.dart';
import 'screens/spares_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/order_summary_screen.dart';
import 'screens/pay_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/customer_details_screen.dart';


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

class AirXpertRoot extends StatefulWidget {
  const AirXpertRoot({super.key});

  @override
  State<AirXpertRoot> createState() => _AirXpertRootState();
}

class _AirXpertRootState extends State<AirXpertRoot> {
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en'; 

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
   
    const primaryColor = Color(0xFF00796B); // Deeper, more professional teal
    const primaryContainer = Color(0xFFB2DFDB);
    const darkBg1 = Color(0xFF121212); // True deep dark mode base
    const darkBg2 = Color(0xFF1E1E1E); // Elevated dark surface
    const greyMedium = Color(0xFF757575); // Neutral medium grey
    const greyLight = Color(0xFFE0E0E0); // Legible light grey
    const bgLight = Color(0xFFF4F6F8); // Very light grey-blue background
    const white = Color(0xFFFFFFFF); 
    const blackText = Color(0xFF212121);

    final colorSchemeLight = ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryContainer,
      secondary: const Color(0xFF009688),
      surface: white,
      surfaceContainer: bgLight,
      onPrimary: white,
      onSurface: blackText,
      onSurfaceVariant: greyMedium,
      error: const Color(0xFFD32F2F),
    );

    final colorSchemeDark = ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: const Color(0xFF004D40),
      secondary: const Color(0xFF4DB6AC),
      surface: darkBg1,
      surfaceContainer: darkBg2,
      onPrimary: white,
      onSurface: greyLight,
      onSurfaceVariant: greyMedium,
      error: const Color(0xFFEF5350),
    );

    final textTheme = GoogleFonts.interTextTheme();

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeLight,
      scaffoldBackgroundColor: bgLight,
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: blackText),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: blackText),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: blackText),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: blackText),
      ),
      visualDensity: VisualDensity.compact,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkBg2,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: blackText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          iconSize: 20,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
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
      scaffoldBackgroundColor: darkBg1,
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: greyLight),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: greyLight),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: greyLight),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: greyLight),
      ),
      cardColor: darkBg2,
      visualDensity: VisualDensity.compact,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg1,
        foregroundColor: greyLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: greyLight,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          iconSize: 20,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
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
        '/feedback': (context) => const FeedbackScreen(),
        '/contact': (context) => const ContactScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/order-summary': (context) => const OrderSummaryScreen(),
        '/pay': (context) => const PayScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/cart': (context) => const CartScreen(),
        '/customer-details': (context) => const CustomerDetailsScreen(),
      },
    );
  }
}

Widget backOrHomeButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    },
    tooltip: 'Back',
  );
}
