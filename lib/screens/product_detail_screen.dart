import 'package:flutter/material.dart';
import 'dart:convert';
import '../main.dart';
import '../models/item.dart';
import '../state/app_state.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    // Very simple specs mock for demo
    final specs = <String, String>{
      t('Capacity', 'திறன்'): product.id == 'p2' ? '2.0 Ton' : '1.5 Ton',
      t('Type', 'வகை'): product.id == 'p2' ? t('Cassette', 'கேஸெட்') : t('Split', 'ஸ்ப்ளிட்'),
      t('Warranty', 'உத்தரவாதம்'): t('1 Year comprehensive', '1 ஆண்டு முழுமை'),
      t('Availability', 'கிடைக்கும் நிலை'): product.inStock ? t('In stock', 'ஸ்டாக்கில் உள்ளது') : t('Out of stock', 'ஸ்டாக் இல்லை'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Product Details', 'பொருள் விவரங்கள்')),
        actions: [
          ListenableBuilder(
            listenable: AppState.instance,
            builder: (context, _) {
              final count = AppState.instance.cartCount;
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
          ListenableBuilder(
            listenable: AppState.instance,
            builder: (context, _) => IconButton(
              onPressed: () {
                AppState.instance.toggleWishlist(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t('Updated wishlist', 'விருப்பப்பட்டியல் புதுப்பிக்கப்பட்டது')),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: Icon(
                AppState.instance.isWishlisted(product.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: AppState.instance.isWishlisted(product.id)
                    ? Colors.red
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Hero(
                tag: 'product-${product.id}',
                child: _renderDetailImage(product.imageUrl),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(t(product.name, product.nameTa), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(t(product.description, product.descriptionTa)),
          const SizedBox(height: 12),
          Text('₹${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Specifications', 'விளக்கங்கள்'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...specs.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(e.key), Text(e.value)],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: product.inStock
                      ? () {
                          AppState.instance.addToCart(CartItem(
                            id: product.id,
                            name: product.name,
                            nameTa: product.nameTa,
                            price: product.price,
                            type: 'product',
                            imageUrl: product.imageUrl,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t('Added to cart', 'கார்டில் சேர்க்கப்பட்டது')),
                              action: SnackBarAction(
                                label: t('View', 'காண்க'),
                                onPressed: () => Navigator.pushNamed(context, '/cart'),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t('Add to Cart', 'கார்டில் சேர்')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: product.inStock
                      ? () {
                          AppState.instance.clearCart();
                          AppState.instance.addToCart(CartItem(
                            id: product.id,
                            name: product.name,
                            nameTa: product.nameTa,
                            price: product.price,
                            type: 'product',
                            imageUrl: product.imageUrl,
                          ));
                          Navigator.pushNamed(context, '/order-summary');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t('Buy Now', 'இப்போதே வாங்க')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _renderDetailImage(String url) {
  if (url.startsWith('data:image')) {
    final base64Data = url.split(',').last;
    final bytes = base64Decode(base64Data);
    return Image.memory(bytes, fit: BoxFit.cover);
  }
  return Image.network(url, fit: BoxFit.cover);
}
