import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../main.dart';
import '../state/app_state.dart';
import 'contact_screen.dart';
import 'products_screen.dart';
import 'service_booking_screen.dart';
import 'spares_screen.dart';
import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;
    final user = AppState.instance.currentUser;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final pages = [
      _UserDashboard(langCode: lang),
      const ProductsScreen(embedInScaffold: false),
      const SparesScreen(embedInScaffold: false),
      const ServiceBookingScreen(),
      const FeedbackScreen(embedInScaffold: false),
      const ContactScreen(embedInScaffold: false),
    ];

    final pageTitles = [
      t('Home', 'முகப்பு'),
      t('Products', 'பொருட்கள்'),
      t('Spares', 'ஸ்பேர் பாகங்கள்'),
      t('Service', 'சேவை'),
      t('Feedback', 'கருத்து'),
      t('Contact', 'தொடர்பு'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_index]),
        actions: [
          ListenableBuilder(
            listenable: AppState.instance,
            builder: (context, _) {
              final cartCount = AppState.instance.cartCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: t('My Cart', 'என் கார்ட்'),
                    icon: const Icon(Icons.shopping_cart_rounded),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            tooltip: t('Call customer care', 'வாடிக்கையாளர் பராமரிப்பிற்கு அழை'),
            icon: const Icon(Icons.call_rounded),
            onPressed: _callCare,
          ),
          IconButton(
            tooltip: t('View location', 'இடத்தை பார்க்க'),
            icon: const Icon(Icons.location_on_rounded),
            onPressed: _openLocation,
          ),
          IconButton(
            tooltip: t('Toggle theme', 'தீம் மாற்று'),
            icon: const Icon(Icons.brightness_6_rounded),
            onPressed: appLang.toggleTheme,
          ),
          PopupMenuButton<String>(
            tooltip: t('Language', 'மொழி'),
            onSelected: appLang.setLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Text(
                  'English',
                  style: TextStyle(
                    fontWeight: appLang.languageCode == 'en'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'ta',
                child: Text(
                  'தமிழ்',
                  style: TextStyle(
                    fontWeight: appLang.languageCode == 'ta'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
            icon: const Icon(Icons.language_rounded),
          ),
          IconButton(
            tooltip: t('Logout', 'வெளியேறு'),
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              AppState.instance.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, lang),
      body: pages[_index],
    );
  }

  // Quick actions for phone and location
  final String _carePhone = '9884775851';
  final String _address = '89/116, Paramathy Road, Opposite Kanna Super Market, Namakkal-637001';

  Future<void> _callCare() async {
    final uri = Uri(scheme: 'tel', path: _carePhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openLocation() async {
    final encoded = Uri.encodeComponent(_address);
    Uri? uri;
    if (Platform.isAndroid) {
      uri = Uri.parse('geo:0,0?q=$encoded');
      if (!await canLaunchUrl(uri)) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
      }
    } else if (Platform.isIOS) {
      uri = Uri.parse('comgooglemaps://?q=$encoded');
      if (!await canLaunchUrl(uri)) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
      }
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildNavigationDrawer(BuildContext context, String lang) {
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Flexible(
                child: Text(
                  'AirXpert',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          _drawerItem(
            context,
            0,
            t('Home', 'முகப்பு'),
            Icons.home_outlined,
          ),
          _drawerItem(
            context,
            1,
            t('Products', 'பொருட்கள்'),
            Icons.shopping_bag_outlined,
          ),
          _drawerItem(
            context,
            2,
            t('Spares', 'ஸ்பேர் பாகங்கள்'),
            Icons.handyman_outlined,
          ),
          _drawerItem(
            context,
            3,
            t('Service', 'சேவை'),
            Icons.build_outlined,
          ),
          _drawerItem(
            context,
            4,
            t('Feedback', 'கருத்து'),
            Icons.feedback_outlined,
          ),
          _drawerItem(
            context,
            5,
            t('Contact', 'தொடர்பு'),
            Icons.phone_outlined,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite_rounded),
            title: Text(t('My Wishlist', 'என் விருப்பப்பட்டியல்')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/wishlist');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t('Cart', 'கார்ட்')),
                ListenableBuilder(
                  listenable: AppState.instance,
                  builder: (context, _) {
                    final count = AppState.instance.cartCount;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: Text(t('My Orders', 'என் ஆர்டர்கள்')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/orders');
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, int index, String title, IconData icon) {
    final isSelected = _index == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pop(context);
        if (mounted) setState(() => _index = index);
      },
    );
  }
}

class _UserDashboard extends StatelessWidget {
  final String langCode;

  const _UserDashboard({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('Keep your AC summer‑ready', 'உங்கள் ஏசியை எப்போதும் குளிர்ச்சியாக வைத்துக்கொள்ளுங்கள்'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t(
                            'Book services, buy spares and track bills in one place.',
                            'சேவை பதிவு, ஸ்பேர் வாங்குதல், பில் அனைத்தையும் ஒரே இடத்தில்.',
                          ),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.ac_unit_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t('Quick actions', 'விரைவு செயல்பாடுகள்'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionCard(
                  icon: Icons.build_circle_rounded,
                  label: t('Book Service', 'சேவை பதிவு'),
                  onTap: () => Navigator.pushNamed(context, '/service'),
                ),
                _QuickActionCard(
                  icon: Icons.shopping_bag_rounded,
                  label: t('AC Products', 'ஏசி பொருட்கள்'),
                  onTap: () => Navigator.pushNamed(context, '/products'),
                ),
                _QuickActionCard(
                  icon: Icons.handyman_rounded,
                  label: t('Spare Parts', 'ஸ்பேர் பாகங்கள்'),
                  onTap: () => Navigator.pushNamed(context, '/spares'),
                ),
                _QuickActionCard(
                  icon: Icons.feedback_rounded,
                  label: t('Feedback', 'கருத்து'),
                  onTap: () => Navigator.pushNamed(context, '/feedback'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
