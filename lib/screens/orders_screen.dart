import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final user = app.currentUser;
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final orders = app.orders.reversed.where((o) => o.userEmail == user?.email).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('My Orders', 'என் ஆர்டர்கள்')),
        leading: backOrHomeButton(context),
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
          final orders = app.orders.reversed.where((o) => o.userEmail == user?.email).toList();
          
          if (orders.isEmpty) {
            return Center(child: Text(t('No orders yet', 'இன்னும் ஆர்டர்கள் இல்லை')));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];
              final date = o.createdAt;
              final dateStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(t('Order', 'ஆர்டர்') + ' #${o.id}'),
                  subtitle: Text('${t('Date', 'தேதி')}: $dateStr • ${t('Status', 'நிலை')}: ${o.status}'),
                  trailing: Text('₹${o.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(t('Order Details', 'ஆர்டர் விவரங்கள்')),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Text(t('Items', 'உருப்படிகள்')),
                              const SizedBox(height: 8),
                              ...o.items.map((it) => ListTile(
                                    dense: true,
                                    title: Text(t(it.name, it.nameTa)),
                                    trailing: Text('₹${it.price.toStringAsFixed(2)} x ${it.quantity}'),
                                  )),
                              const Divider(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(t('Total', 'மொத்தம்') + ': ₹${o.total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                              )
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(t('Close', 'மூடு')))
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
