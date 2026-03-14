import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final orders = AppState.instance.orders.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('My Orders', 'என் ஆர்டர்கள்')),
        leading: backOrHomeButton(context),
      ),
      body: orders.isEmpty
          ? Center(child: Text(t('No orders yet', 'இன்னும் ஆர்டர்கள் இல்லை')))
          : ListView.builder(
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
                                      title: Text(it.name),
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
            ),
    );
  }
}
