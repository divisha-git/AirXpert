import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final colorScheme = Theme.of(context).colorScheme;
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('My Cart', 'என் கார்ட்')),
        leading: backOrHomeButton(context),
        actions: [
          IconButton(
            onPressed: () {
              app.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t('Cart cleared', 'கார்ட் நீக்கப்பட்டது'))),
              );
            },
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: t('Clear cart', 'கார்டை நீக்கு'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final items = app.cartItems;
          final total = app.cartTotal;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    t('Your cart is empty', 'உங்கள் கார்ட் காலியாக உள்ளது'),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: Text(t('Start Shopping', 'ஷாப்பிங் செய்ய')),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: _renderCartImage(item.imageUrl),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t(item.name, item.nameTa),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t(item.type.toUpperCase(), item.type.toUpperCase()),
                                    style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)} x ${item.quantity}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                      ),
                                      Text(
                                        '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                        style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => app.removeFromCart(item.id, item.type),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              tooltip: t('Remove', 'நீக்கு'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t('Total Amount', 'மொத்த தொகை'),
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/order-summary');
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          t('Proceed to Checkout', 'செக்அவுட் செய்ய'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _renderCartImage(String? url) {
  if (url == null || url.isEmpty) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
    );
  }
  if (url.startsWith('data:image')) {
    try {
      final base64Data = url.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
      );
    }
  }
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
      );
    },
  );
}
