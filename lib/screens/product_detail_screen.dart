import 'package:flutter/material.dart';
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
      t('Availability', 'கிடைக்கும் நிலை'): t('In stock', 'ஸ்டாக்கில் உள்ளது'),
    };

    return Scaffold(
      appBar: AppBar(title: Text(t('Product Details', 'பொருள் விவரங்கள்'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Text(product.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(product.description),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AppState.instance.clearCart();
                AppState.instance.addToCart(CartItem(id: product.id, name: product.name, price: product.price, type: 'product'));
                Navigator.pushNamed(context, '/order-summary');
              },
              child: Text(t('Buy Now', 'இப்போதே வாங்க')), 
            ),
          )
        ],
      ),
    );
  }
}
