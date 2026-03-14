import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final items = app.cartItems;
    final total = app.cartTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('My Cart', 'என் கார்ட்')),
        leading: backOrHomeButton(context),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              onPressed: () {
                app.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('Cart cleared', 'கார்ட் நீக்கப்பட்டது'))),
                );
                (context as Element).markNeedsBuild();
              },
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: t('Clear cart', 'கார்டை நீக்கு'),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(child: Text(t('Your cart is empty', 'உங்கள் கார்ட் காலியாக உள்ளது')))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(item.type[0].toUpperCase()),
                          ),
                          title: Text(item.name),
                          subtitle: Text(t('Quantity', 'அளவு') + ': ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                              IconButton(
                                onPressed: () {
                                  app.removeFromCart(item.id, item.type);
                                  (context as Element).markNeedsBuild();
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                tooltip: t('Remove', 'நீக்கு'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t('Total', 'மொத்தம்'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/order-summary');
                      },
                      child: Text(t('Buy Now', 'இப்போதே வாங்க')),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
