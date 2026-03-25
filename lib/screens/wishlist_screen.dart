import 'package:flutter/material.dart';
import '../main.dart';
import '../models/item.dart';
import '../state/app_state.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('My Wishlist', 'என் விருப்பப்பட்டியல்')),
        actions: [
          ListenableBuilder(
            listenable: app,
            builder: (context, _) {
              final count = app.cartCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  if (count > 0)
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
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final products = app.products.where((p) => app.wishlist.contains(p.id)).toList();
          final spares = app.spares.where((s) => app.wishlist.contains(s.id)).toList();
          
          if (products.isEmpty && spares.isEmpty) {
            return Center(child: Text(t('No items in wishlist', 'விருப்பப்பட்டியலில் எதுவும் இல்லை')));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (products.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                  child: Text(t('Products', 'தயாரிப்புகள்'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...products.map((p) => _WishlistItem(
                  id: p.id,
                  name: p.name,
                  nameTa: p.nameTa,
                  price: p.price,
                  imageUrl: p.imageUrl,
                  type: 'product',
                  langCode: lang,
                )),
              ],
              if (spares.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
                  child: Text(t('Spare Parts', 'ஸ்பேர் பாகங்கள்'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...spares.map((s) => _WishlistItem(
                  id: s.id,
                  name: s.name,
                  nameTa: s.nameTa,
                  price: s.price,
                  imageUrl: s.imageUrl,
                  type: 'spare',
                  langCode: lang,
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WishlistItem extends StatelessWidget {
  final String id;
  final String name;
  final String nameTa;
  final double price;
  final String imageUrl;
  final String type;
  final String langCode;

  const _WishlistItem({
    required this.id,
    required this.name,
    required this.nameTa,
    required this.price,
    required this.imageUrl,
    required this.type,
    required this.langCode,
  });

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
        title: Text(t(name, nameTa)),
        subtitle: Text('₹${price.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => app.toggleWishlist(id),
              icon: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent),
            ),
            IconButton(
              onPressed: () {
                app.clearCart();
                app.addToCart(CartItem(
                  id: id,
                  name: name,
                  nameTa: nameTa,
                  price: price,
                  type: type,
                ));
                Navigator.pushNamed(context, '/order-summary');
              },
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
