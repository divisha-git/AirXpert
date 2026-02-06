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

    final products = app.products.where((p) => app.wishlist.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('My Wishlist', 'என் விருப்பப்பட்டியல்'))),
      body: products.isEmpty
          ? Center(child: Text(t('No items in wishlist', 'விருப்பப்பட்டியலில் எதுவும் இல்லை')))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(p.imageUrl)),
                    title: Text(p.name),
                    subtitle: Text('₹${p.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            app.toggleWishlist(p.id);
                            (context as Element).markNeedsBuild();
                          },
                          icon: const Icon(Icons.favorite_border_rounded),
                        ),
                        IconButton(
                          onPressed: () {
                            app.clearCart();
                            app.addToCart(CartItem(id: p.id, name: p.name, price: p.price, type: 'product'));
                            Navigator.pushNamed(context, '/order-summary');
                          },
                          icon: const Icon(Icons.shopping_cart_checkout_rounded),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
