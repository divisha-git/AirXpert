import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'dart:convert';
import '../main.dart';
import '../models/item.dart';
import '../state/app_state.dart';
import 'billing_screen.dart';

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
      _OrdersPage(langCode: lang),
      _PaymentsPage(langCode: lang),
      _BillingAdminPage(langCode: lang),
      _FeedbackAdminPage(langCode: lang),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            t(
              'Welcome, ${user?.name ?? 'Admin'}',
              'வணக்கம், ${user?.name ?? 'நிர்வாகி'}',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) => pages[_selectedPageIndex],
      ),
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
                Flexible(
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
          _buildDrawerItem(
            context,
            4,
            t('Orders', 'ஆர்டர்கள்'),
            Icons.inventory_2_outlined,
            lang,
          ),
          _buildDrawerItem(
            context,
            5,
            t('Payments', 'கட்டணங்கள்'),
            Icons.receipt_long_rounded,
            lang,
          ),
          _buildDrawerItem(
            context,
            6,
            t('Billing', 'பில்'),
            Icons.receipt_rounded,
            lang,
          ),
          _buildDrawerItem(
            context,
            7,
            t('Feedback', 'கருத்து'),
            Icons.feedback_rounded,
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
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withOpacity(0.5),
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
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
        if (mounted) {
          setState(() => _selectedPageIndex = index);
        }
      },
    );
  }
}

class _BillingAdminPage extends StatelessWidget {
  final String langCode;
  const _BillingAdminPage({required this.langCode});
  @override
  Widget build(BuildContext context) {
    return BillingScreen(embedInScaffold: false);
  }
}

class _FeedbackAdminPage extends StatelessWidget {
  final String langCode;
  const _FeedbackAdminPage({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final feedbacks = AppState.instance.feedbacks;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            t('Customer Feedback', 'வாடிக்கையாளர் கருத்துகள்'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: feedbacks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.feedback_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No feedback yet', 'இன்னும் கருத்துகள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final f = feedbacks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            f.userName.isNotEmpty
                                ? f.userName[0].toUpperCase()
                                : 'U',
                          ),
                        ),
                        title: Text(f.userName),
                        subtitle: Text('${f.userEmail} • ${f.rating}/5'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(f.userName),
                              content: Text(f.message),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
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
            children: [
              Expanded(
                child: Text(
                  t('AC Products', 'ஏசி பொருட்கள்'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No products yet', 'இன்னும் பொருட்கள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
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
                        leading: Container(
                          width: 50,
                          height: 50,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _renderImage(p.imageUrl),
                        ),
                        title: Text(t(p.name, p.nameTa)),
                        subtitle: Text('₹${p.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _showEditProductDialog(context, p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                AppState.instance.deleteProduct(p.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t(
                                        'Product deleted',
                                        'பொருள் நீக்கப்பட்டது',
                                      ),
                                    ),
                                  ),
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
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;
    final colorScheme = Theme.of(context).colorScheme;

    final name = TextEditingController();
    final nameTa = TextEditingController();
    final desc = TextEditingController();
    final descTa = TextEditingController();
    final price = TextEditingController();
    final image = TextEditingController(
      text:
          'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
    );
    bool inStock = true;

    Future<void> pickImage() async {
      final choice = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file_rounded),
                  title: const Text('Files'),
                  onTap: () => Navigator.pop(context, 'files'),
                ),
                ListTile(
                  leading: const Icon(Icons.link_rounded),
                  title: const Text('Paste URL'),
                  onTap: () => Navigator.pop(context, 'url'),
                ),
              ],
            ),
          ),
        ),
      );
      if (choice == 'gallery') {
        final picker = ImagePicker();
        final x = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (x != null) {
          final bytes = await x.readAsBytes();
          final ext = x.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
          image.text = 'data:image/$ext;base64,${base64Encode(bytes)}';
        }
      } else if (choice == 'files') {
        final result = await fp.FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: fp.FileType.image,
          allowCompression: true,
          withData: true,
        );
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.single.bytes != null) {
          final f = result.files.single;
          final ext = (f.extension ?? 'jpeg').toLowerCase();
          image.text = 'data:image/$ext;base64,${base64Encode(f.bytes!)}';
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Add Product', 'பொருள் சேர்'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  context,
                  name,
                  t('Name (EN)', 'பெயர் (EN)'),
                  Icons.title_rounded,
                ),
                _buildField(
                  context,
                  nameTa,
                  t('Name (TA)', 'பெயர் (TA)'),
                  Icons.translate_rounded,
                ),
                _buildField(
                  context,
                  desc,
                  t('Description (EN)', 'விளக்கம் (EN)'),
                  Icons.description_rounded,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  descTa,
                  t('Description (TA)', 'விளக்கம் (TA)'),
                  Icons.description_outlined,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  price,
                  t('Price', 'விலை'),
                  Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                ),
                _buildField(context, image, 'Image URL', Icons.link_rounded),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.upload_rounded, size: 20),
                    label: Text(t('Upload Image', 'படத்தை பதிவேற்று')),
                    onPressed: pickImage,
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setStateSB) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        t('In Stock', 'ஸ்டாக் உள்ளது'),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      value: inStock,
                      activeColor: colorScheme.primary,
                      onChanged: (v) => setStateSB(() => inStock = v),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        t('Cancel', 'ரத்து'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final pVal = double.tryParse(price.text.trim()) ?? 0;
                        final id = 'p${DateTime.now().millisecondsSinceEpoch}';

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await AppState.instance.addProduct(
                          Product(
                            id: id,
                            name: name.text.trim(),
                            nameTa: nameTa.text.trim(),
                            description: desc.text.trim(),
                            descriptionTa: descTa.text.trim(),
                            price: pVal,
                            imageUrl: image.text.trim(),
                            inStock: inStock,
                          ),
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context); // Remove loading
                        Navigator.pop(context); // Remove dialog

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              t(
                                'Product added. Visible in store.',
                                'பொருள் சேர்க்கப்பட்டது. கடையில் காணப்படும்.',
                              ),
                            ),
                            action: SnackBarAction(
                              label: t('View', 'காண்க'),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/products'),
                            ),
                          ),
                        );
                      },
                      child: Text(t('Add', 'சேர்')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;
    final colorScheme = Theme.of(context).colorScheme;

    final name = TextEditingController(text: product.name);
    final nameTa = TextEditingController(text: product.nameTa);
    final desc = TextEditingController(text: product.description);
    final descTa = TextEditingController(text: product.descriptionTa);
    final price = TextEditingController(text: product.price.toStringAsFixed(0));
    final image = TextEditingController(text: product.imageUrl);
    bool inStock = product.inStock;

    Future<void> pickImage() async {
      final choice = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file_rounded),
                  title: const Text('Files'),
                  onTap: () => Navigator.pop(context, 'files'),
                ),
                ListTile(
                  leading: const Icon(Icons.link_rounded),
                  title: const Text('Paste URL'),
                  onTap: () => Navigator.pop(context, 'url'),
                ),
              ],
            ),
          ),
        ),
      );
      if (choice == 'gallery') {
        final picker = ImagePicker();
        final x = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (x != null) {
          final bytes = await x.readAsBytes();
          final ext = x.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
          image.text = 'data:image/$ext;base64,${base64Encode(bytes)}';
        }
      } else if (choice == 'files') {
        final result = await fp.FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: fp.FileType.image,
          allowCompression: true,
          withData: true,
        );
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.single.bytes != null) {
          final f = result.files.single;
          final ext = (f.extension ?? 'jpeg').toLowerCase();
          image.text = 'data:image/$ext;base64,${base64Encode(f.bytes!)}';
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Edit Product', 'பொருள் திருத்து'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  context,
                  name,
                  t('Name (EN)', 'பெயர் (EN)'),
                  Icons.title_rounded,
                ),
                _buildField(
                  context,
                  nameTa,
                  t('Name (TA)', 'பெயர் (TA)'),
                  Icons.translate_rounded,
                ),
                _buildField(
                  context,
                  desc,
                  t('Description (EN)', 'விளக்கம் (EN)'),
                  Icons.description_rounded,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  descTa,
                  t('Description (TA)', 'விளக்கம் (TA)'),
                  Icons.description_outlined,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  price,
                  t('Price', 'விலை'),
                  Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                ),
                _buildField(context, image, 'Image URL', Icons.link_rounded),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.upload_rounded, size: 20),
                    label: Text(t('Upload Image', 'படத்தை பதிவேற்று')),
                    onPressed: pickImage,
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setStateSB) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        t('In Stock', 'ஸ்டாக் உள்ளது'),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      value: inStock,
                      activeColor: colorScheme.primary,
                      onChanged: (v) => setStateSB(() => inStock = v),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        t('Cancel', 'ரத்து'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final pVal =
                            double.tryParse(price.text.trim()) ?? product.price;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await AppState.instance.updateProduct(
                          Product(
                            id: product.id,
                            name: name.text.trim(),
                            nameTa: nameTa.text.trim(),
                            description: desc.text.trim(),
                            descriptionTa: descTa.text.trim(),
                            price: pVal,
                            imageUrl: image.text.trim(),
                            inStock: inStock,
                          ),
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context); // Remove loading
                        Navigator.pop(context); // Remove dialog
                      },
                      child: Text(t('Save', 'சேமிக்க')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
            children: [
              Expanded(
                child: Text(
                  t('AC Spare Parts', 'ஏசி ஸ்பேர் பாகங்கள்'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddSpareDialog(context),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t(
                          'No spare parts yet',
                          'இன்னும் ஸ்பேர் பாகங்கள் இல்லை',
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
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
                        leading: Container(
                          width: 50,
                          height: 50,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _renderImage(s.imageUrl),
                        ),
                        title: Text(t(s.name, s.nameTa)),
                        subtitle: Text('₹${s.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showEditSpareDialog(context, s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                AppState.instance.deleteSpare(s.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t(
                                        'Spare deleted',
                                        'ஸ்பேர் நீக்கப்பட்டது',
                                      ),
                                    ),
                                  ),
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

  void _showAddSpareDialog(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final name = TextEditingController();
    final nameTa = TextEditingController();
    final desc = TextEditingController();
    final descTa = TextEditingController();
    final price = TextEditingController();
    final image = TextEditingController(
      text:
          'https://commons.wikimedia.org/wiki/Special:FilePath/MitsubishiAirConditioners.jpg',
    );
    bool inStock = true;
    Future<void> pickImage() async {
      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Files'),
                onTap: () => Navigator.pop(context, 'files'),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Paste URL'),
                onTap: () => Navigator.pop(context, 'url'),
              ),
            ],
          ),
        ),
      );
      if (choice == 'gallery') {
        final picker = ImagePicker();
        final x = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (x != null) {
          final bytes = await x.readAsBytes();
          final ext = x.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
          image.text = 'data:image/$ext;base64,${base64Encode(bytes)}';
        }
      } else if (choice == 'files') {
        final result = await fp.FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: fp.FileType.image,
          allowCompression: true,
          withData: true,
        );
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.single.bytes != null) {
          final f = result.files.single;
          final ext = (f.extension ?? 'jpeg').toLowerCase();
          image.text = 'data:image/$ext;base64,${base64Encode(f.bytes!)}';
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('Add Spare', 'ஸ்பேர் சேர்')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: t('Name (EN)', 'பெயர் (EN)'),
                ),
              ),
              TextField(
                controller: nameTa,
                decoration: InputDecoration(
                  labelText: t('Name (TA)', 'பெயர் (TA)'),
                ),
              ),
              TextField(
                controller: desc,
                decoration: InputDecoration(
                  labelText: t('Description (EN)', 'விளக்கம் (EN)'),
                ),
              ),
              TextField(
                controller: descTa,
                decoration: InputDecoration(
                  labelText: t('Description (TA)', 'விளக்கம் (TA)'),
                ),
              ),
              TextField(
                controller: price,
                decoration: InputDecoration(labelText: t('Price', 'விலை')),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: image,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: Text(t('Upload Image', 'படத்தை பதிவேற்று')),
                  onPressed: pickImage,
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setStateSB) => SwitchListTile(
                  title: Text(t('In Stock', 'ஸ்டாக் உள்ளது')),
                  value: inStock,
                  onChanged: (v) => setStateSB(() => inStock = v),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('Cancel', 'ரத்து')),
          ),
          ElevatedButton(
            onPressed: () async {
              final pVal = double.tryParse(price.text.trim()) ?? 0;
              final id = 's${DateTime.now().millisecondsSinceEpoch}';

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              await AppState.instance.addSpare(
                SparePart(
                  id: id,
                  name: name.text.trim(),
                  nameTa: nameTa.text.trim(),
                  description: desc.text.trim(),
                  descriptionTa: descTa.text.trim(),
                  price: pVal,
                  imageUrl: image.text.trim(),
                  inStock: inStock,
                ),
              );

              if (!context.mounted) return;
              Navigator.pop(context); // Remove loading
              Navigator.pop(context); // Remove dialog
            },
            child: Text(t('Add', 'சேர்')),
          ),
        ],
      ),
    );
  }

  void _showEditSpareDialog(BuildContext context, SparePart spare) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final name = TextEditingController(text: spare.name);
    final nameTa = TextEditingController(text: spare.nameTa);
    final desc = TextEditingController(text: spare.description);
    final descTa = TextEditingController(text: spare.descriptionTa);
    final price = TextEditingController(text: spare.price.toStringAsFixed(0));
    final image = TextEditingController(text: spare.imageUrl);
    bool inStock = spare.inStock;
    Future<void> pickImage() async {
      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Files'),
                onTap: () => Navigator.pop(context, 'files'),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Paste URL'),
                onTap: () => Navigator.pop(context, 'url'),
              ),
            ],
          ),
        ),
      );
      if (choice == 'gallery') {
        final picker = ImagePicker();
        final x = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (x != null) {
          final bytes = await x.readAsBytes();
          final ext = x.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
          image.text = 'data:image/$ext;base64,${base64Encode(bytes)}';
        }
      } else if (choice == 'files') {
        final result = await fp.FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: fp.FileType.image,
          allowCompression: true,
          withData: true,
        );
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.single.bytes != null) {
          final f = result.files.single;
          final ext = (f.extension ?? 'jpeg').toLowerCase();
          image.text = 'data:image/$ext;base64,${base64Encode(f.bytes!)}';
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('Edit Spare', 'ஸ்பேர் திருத்து')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: t('Name (EN)', 'பெயர் (EN)'),
                ),
              ),
              TextField(
                controller: nameTa,
                decoration: InputDecoration(
                  labelText: t('Name (TA)', 'பெயர் (TA)'),
                ),
              ),
              TextField(
                controller: desc,
                decoration: InputDecoration(
                  labelText: t('Description (EN)', 'விளக்கம் (EN)'),
                ),
              ),
              TextField(
                controller: descTa,
                decoration: InputDecoration(
                  labelText: t('Description (TA)', 'விளக்கம் (TA)'),
                ),
              ),
              TextField(
                controller: price,
                decoration: InputDecoration(labelText: t('Price', 'விலை')),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: image,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: Text(t('Upload Image', 'படத்தை பதிவேற்று')),
                  onPressed: pickImage,
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setStateSB) => SwitchListTile(
                  title: Text(t('In Stock', 'ஸ்டாக் உள்ளது')),
                  value: inStock,
                  onChanged: (v) => setStateSB(() => inStock = v),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('Cancel', 'ரத்து')),
          ),
          ElevatedButton(
            onPressed: () async {
              final pVal = double.tryParse(price.text.trim()) ?? spare.price;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              await AppState.instance.updateSpare(
                SparePart(
                  id: spare.id,
                  name: name.text.trim(),
                  nameTa: nameTa.text.trim(),
                  description: desc.text.trim(),
                  descriptionTa: descTa.text.trim(),
                  price: pVal,
                  imageUrl: image.text.trim(),
                  inStock: inStock,
                ),
              );

              if (!context.mounted) return;
              Navigator.pop(context); // Remove loading
              Navigator.pop(context); // Remove dialog
            },
            child: Text(t('Save', 'சேமிக்க')),
          ),
        ],
      ),
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
            children: [
              Expanded(
                child: Text(
                  t('Service Types', 'சேவை வகைகள்'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(context),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No services yet', 'இன்னும் சேவைகள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
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
                        title: Text(t(s.name, s.nameTa)),
                        subtitle: Text('₹${s.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _showEditServiceDialog(context, s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                AppState.instance.deleteService(s.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t(
                                        'Service deleted',
                                        'சேவை நீக்கப்பட்டது',
                                      ),
                                    ),
                                  ),
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

  void _showAddServiceDialog(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;
    final colorScheme = Theme.of(context).colorScheme;

    final name = TextEditingController();
    final nameTa = TextEditingController();
    final desc = TextEditingController();
    final descTa = TextEditingController();
    final price = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Add Service', 'சேவை சேர்'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  context,
                  name,
                  t('Name (EN)', 'பெயர் (EN)'),
                  Icons.title_rounded,
                ),
                _buildField(
                  context,
                  nameTa,
                  t('Name (TA)', 'பெயர் (TA)'),
                  Icons.translate_rounded,
                ),
                _buildField(
                  context,
                  desc,
                  t('Description (EN)', 'விளக்கம் (EN)'),
                  Icons.description_rounded,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  descTa,
                  t('Description (TA)', 'விளக்கம் (TA)'),
                  Icons.description_outlined,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  price,
                  t('Price', 'விலை'),
                  Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        t('Cancel', 'ரத்து'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final pVal = double.tryParse(price.text.trim()) ?? 0;
                        final id =
                            'svc${DateTime.now().millisecondsSinceEpoch}';

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await AppState.instance.addService(
                          ServiceType(
                            id: id,
                            name: name.text.trim(),
                            nameTa: nameTa.text.trim(),
                            description: desc.text.trim(),
                            descriptionTa: descTa.text.trim(),
                            price: pVal,
                          ),
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context); // Remove loading
                        Navigator.pop(context); // Remove dialog
                      },
                      child: Text(t('Add', 'சேர்')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, ServiceType s) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;
    final colorScheme = Theme.of(context).colorScheme;

    final name = TextEditingController(text: s.name);
    final nameTa = TextEditingController(text: s.nameTa);
    final desc = TextEditingController(text: s.description);
    final descTa = TextEditingController(text: s.descriptionTa);
    final price = TextEditingController(text: s.price.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Edit Service', 'சேவை திருத்து'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  context,
                  name,
                  t('Name (EN)', 'பெயர் (EN)'),
                  Icons.title_rounded,
                ),
                _buildField(
                  context,
                  nameTa,
                  t('Name (TA)', 'பெயர் (TA)'),
                  Icons.translate_rounded,
                ),
                _buildField(
                  context,
                  desc,
                  t('Description (EN)', 'விளக்கம் (EN)'),
                  Icons.description_rounded,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  descTa,
                  t('Description (TA)', 'விளக்கம் (TA)'),
                  Icons.description_outlined,
                  maxLines: 2,
                ),
                _buildField(
                  context,
                  price,
                  t('Price', 'விலை'),
                  Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        t('Cancel', 'ரத்து'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final pVal =
                            double.tryParse(price.text.trim()) ?? s.price;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await AppState.instance.updateService(
                          ServiceType(
                            id: s.id,
                            name: name.text.trim(),
                            nameTa: nameTa.text.trim(),
                            description: desc.text.trim(),
                            descriptionTa: descTa.text.trim(),
                            price: pVal,
                          ),
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context); // Remove loading
                        Navigator.pop(context); // Remove dialog
                      },
                      child: Text(t('Save', 'சேமிக்க')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No customers yet', 'இன்னும் வாடிக்கையாளர்கள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
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

// Orders Page
class _OrdersPage extends StatelessWidget {
  final String langCode;
  const _OrdersPage({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final orders = AppState.instance.orders.reversed.toList();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            t('Orders', 'ஆர்டர்கள்'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No orders yet', 'இன்னும் ஆர்டர்கள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: orders.length,
                  itemBuilder: (context, i) {
                    final o = orders[i];
                    final d = o.createdAt;
                    final dateStr =
                        '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag_rounded),
                        title: Text(
                          '${t('Order', 'ஆர்டர்')} #${o.id} • ₹${o.total.toStringAsFixed(2)}',
                        ),
                        subtitle: Text(
                          '${o.userEmail} • $dateStr • ${t('Status', 'நிலை')}: ${o.status}',
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

// Payments Page
class _PaymentsPage extends StatelessWidget {
  final String langCode;
  const _PaymentsPage({required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final payments = AppState.instance.payments.reversed.toList();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            t('Payments', 'கட்டணங்கள்'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('No payments yet', 'இன்னும் கட்டணங்கள் இல்லை'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: payments.length,
                  itemBuilder: (context, i) {
                    final p = payments[i];
                    final d = p.date;
                    final dateStr =
                        '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.payment_rounded),
                        title: Text('₹${p.amount.toStringAsFixed(2)}'),
                        subtitle: Text(
                          '${t('Method', 'முறை')}: ${p.method} • ${t('Date', 'தேதி')}: $dateStr',
                        ),
                        trailing: Text(
                          p.id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
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

Widget _buildField(
  BuildContext context,
  TextEditingController controller,
  String label,
  IconData icon, {
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
  );
}

Widget _renderImage(String url) {
  if (url.isEmpty) return const SizedBox.shrink();
  if (url.startsWith('data:image')) {
    try {
      final base64String = url.replaceFirst(
        RegExp(r'data:image/[^;]+;base64,'),
        '',
      );
      final bytes = base64Decode(base64String);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.image_not_supported_outlined);
    }
  }
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.image_not_supported_outlined),
  );
}
