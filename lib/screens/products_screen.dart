import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item.dart';
import '../state/app_state.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  final bool embedInScaffold;

  const ProductsScreen({super.key, this.embedInScaffold = true});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final products = app.products;
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    String _nameTa(String id, String fallback) {
      if (lang != 'ta') return fallback;
      switch (id) {
        case 'p1':
          return '1.5 டன் இன்வெர்டர் ஏசி';
        case 'p2':
          return '2 டன் கேஸெட் ஏசி';
        default:
          return fallback;
      }
    }

    String _descTa(String id, String fallback) {
      if (lang != 'ta') return fallback;
      switch (id) {
        case 'p1':
          return 'உயர் திறன் ஸ்ப்ளிட் ஏசி, விரைவு குளிர்ச்சி.';
        case 'p2':
          return 'கடைகள் மற்றும் அலுவலகங்களுக்கு சிறந்தது.';
        default:
          return fallback;
      }
    }

    Widget content = GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final Product p = products[index];
        return _ProductCard(product: p, langCode: lang, nameTa: _nameTa(p.id, p.name), descTa: _descTa(p.id, p.description));
      },
    );

    if (!embedInScaffold) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('AC Products', 'ஏசி பொருட்கள்')),
        automaticallyImplyLeading: true,
      ),
      body: content,
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String langCode;
  final String nameTa;
  final String descTa;

  const _ProductCard({required this.product, required this.langCode, required this.nameTa, required this.descTa});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = langCode == 'ta' ? nameTa : product.name;
    final displayDesc = langCode == 'ta' ? descTa : product.description;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Ink.image(
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayDesc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: t('Wishlist', 'விருப்பப்பட்டியல்'),
                          onPressed: () {
                            AppState.instance.toggleWishlist(product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t('Updated wishlist', 'விருப்பப்பட்டியல் புதுப்பிக்கப்பட்டது'))),
                            );
                            (context as Element).markNeedsBuild();
                          },
                          icon: Icon(
                            AppState.instance.isWishlisted(product.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: AppState.instance.isWishlisted(product.id)
                                ? Colors.pinkAccent
                                : null,
                          ),
                        ),
                        IconButton.filledTonal(
                      onPressed: () {
                        AppState.instance.addToCart(
                          CartItem(
                            id: product.id,
                            name: displayName,
                            price: product.price,
                            type: 'product',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              t(
                                '$displayName added to cart',
                                '$displayName கார்டில் சேர்க்கப்பட்டது',
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      iconSize: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
