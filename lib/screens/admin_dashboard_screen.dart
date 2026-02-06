import 'package:flutter/material.dart';
import '../main.dart';
import '../models/item.dart';
import '../state/app_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedPageIndex = 0; // Products, Spares, Services, Customers

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;
    final user = AppState.instance.currentUser;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final pages = [
      _ProductsPage(langCode: lang),
      _SparesPage(langCode: lang),
      _ServicesPage(langCode: lang),
      _CustomersPage(langCode: lang),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Welcome, ${user?.name ?? 'Admin'}', 'வணக்கம், ${user?.name ?? 'நிர்வாகி'}')),
        actions: [
          IconButton(
            tooltip: t('Theme', 'தீம்'),
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => appLang.toggleTheme(),
          ),
          PopupMenuButton<String>(
            tooltip: t('Language', 'மொழி'),
            icon: const Icon(Icons.language_rounded),
            onSelected: appLang.setLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text('English'),
                    if (lang == 'en')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ta',
                child: Row(
                  children: [
                    const Text('தமிழ்'),
                    if (lang == 'ta')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: t('Logout', 'வெளியேறு'),
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              AppState.instance.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, lang),
      body: pages[_selectedPageIndex],
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  t('Navigation', 'வழிசெலுத்தல்'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            0,
            t('Products', 'பொருட்கள்'),
            Icons.shopping_bag_outlined,
            lang,
          ),
          _buildDrawerItem(
            context,
            1,
            t('Spares', 'ஸ்பேர் பாகங்கள்'),
            Icons.handyman_outlined,
            lang,
          ),
          _buildDrawerItem(
            context,
            2,
            t('Services', 'சேவைகள்'),
            Icons.build_outlined,
            lang,
          ),
          _buildDrawerItem(
            context,
            3,
            t('Customers', 'வாடிக்கையாளர்கள்'),
            Icons.people_outlined,
            lang,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    int index,
    String title,
    IconData icon,
    String lang,
  ) {
    final isSelected = _selectedPageIndex == index;
    return ListTile(
      selected: isSelected,
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (mounted) {
          setState(() => _selectedPageIndex = index);
        }
      },
    );
  }
}

// Products Page
class _ProductsPage extends StatelessWidget {
  final String langCode;
  const _ProductsPage({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final products = app.products;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('AC Products', 'ஏசி பொருட்கள்'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(t('Add Product', 'பொருள் சேர்')),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No products yet', 'இன்னும் பொருட்கள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(p.name),
                        subtitle: Text('₹${p.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showEditProductDialog(context, p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                AppState.instance.deleteProduct(p.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t('Product deleted', 'பொருள் நீக்கப்பட்டது'))),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddProductDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('Add product feature coming soon', 'பொருள் சேர்க்கும் வசதி விரைவில் வரும்'))),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('Edit product feature coming soon', 'பொருள் திருத்தும் வசதி விரைவில் வரும்'))),
    );
  }
}

// Spares Page
class _SparesPage extends StatelessWidget {
  final String langCode;
  const _SparesPage({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final spares = app.spares;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('AC Spare Parts', 'ஏசி ஸ்பேர் பாகங்கள்'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('Add spare feature coming soon', 'ஸ்பேர் சேர்க்கும் வசதி விரைவில் வரும்'))),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(t('Add Spare', 'ஸ்பேர் சேர்')),
              ),
            ],
          ),
        ),
        Expanded(
          child: spares.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.handyman_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No spare parts yet', 'இன்னும் ஸ்பேர் பாகங்கள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: spares.length,
                  itemBuilder: (context, index) {
                    final s = spares[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(s.name),
                        subtitle: Text('₹${s.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t('Edit spare feature coming soon', 'ஸ்பேர் திருத்தும் வசதி விரைவில் வரும்'))),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                AppState.instance.deleteSpare(s.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t('Spare deleted', 'ஸ்பேர் நீக்கப்பட்டது'))),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Services Page
class _ServicesPage extends StatelessWidget {
  final String langCode;
  const _ServicesPage({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final services = app.services;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('Service Types', 'சேவை வகைகள்'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('Add service feature coming soon', 'சேவை சேர்க்கும் வசதி விரைவில் வரும்'))),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(t('Add Service', 'சேவை சேர்')),
              ),
            ],
          ),
        ),
        Expanded(
          child: services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No services yet', 'இன்னும் சேவைகள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final s = services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(s.name),
                        subtitle: Text('₹${s.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t('Edit service feature coming soon', 'சேவை திருத்தும் வசதி விரைவில் வரும்'))),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                AppState.instance.deleteService(s.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t('Service deleted', 'சேவை நீக்கப்பட்டது'))),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Customers Page
class _CustomersPage extends StatelessWidget {
  final String langCode;
  const _CustomersPage({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final users = app.registeredUsers;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            t('Registered Customers', 'பதிவுசெய்யப்பட்ட வாடிக்கையாளர்கள்'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No customers yet', 'இன்னும் வாடிக்கையாளர்கள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(u.name[0].toUpperCase()),
                        ),
                        title: Text(u.name),
                        subtitle: Text('${u.email} • ${u.role}'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}