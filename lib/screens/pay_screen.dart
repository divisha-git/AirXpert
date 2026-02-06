import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../state/app_state.dart';

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final upiId = 'airxpert@upi';
    final amount = AppState.instance.totalAmount.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: Text(t('Pay using QR', 'QR மூலம் பணம் செலுத்தவும்'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Icon(Icons.qr_code_2, size: 200),
                ),
              ),
            ),
            Text(
              t('Scan the QR with any UPI app', 'ஏதேனும் UPI ஆப்பில் QR-ஐ ஸ்கேன் செய்யவும்'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t('Amount', 'தொகை') + ': '),
                Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('upi://pay?pa=$upiId&pn=AirXpert&am=$amount&cu=INR');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(t('Open UPI app', 'UPI ஆப்பை திறக்க')),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final order = AppState.instance.placeOrderFromCart(status: 'paid');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('Payment success. Order #', 'கட்டணம் வெற்றி. ஆர்டர் #') + order.id)),
                );
                Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => r.settings.name == '/home');
              },
              child: Text(t('I have paid. Continue', 'நான் கட்டணம் செலுத்திவிட்டேன். தொடரவும்')),
            )
          ],
        ),
      ),
    );
  }
}
