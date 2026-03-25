import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../state/app_state.dart';

class ContactScreen extends StatelessWidget {
  final bool embedInScaffold;

  const ContactScreen({super.key, this.embedInScaffold = true});

  final String shopName = 'AirXpert AC Services';
  final String address = '89/116, Paramathy Road, Opposite Kanna Super Market, Namakkal-637001';
  final String phone = '9884775851';

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _whatsapp() async {
    // Normalize phone and ensure country code (India default +91)
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      digits = '91$digits';
    }
    final waApp = Uri.parse('whatsapp://send?phone=$digits');
    final waWeb = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(waApp)) {
      await launchUrl(waApp, mode: LaunchMode.externalApplication);
      return;
    }
    if (await canLaunchUrl(waWeb)) {
      await launchUrl(waWeb, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final shopNameTa = 'ஏர்எக்ஸ்பர்ட் ஏசி சேவைகள்';
    final addressTa = '89/116, பரமாத்தி ரோடு, கன்னா சூப்பர் மார்க்கெட் எதிரில், நாமக்கல்-637001';

    Widget body = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang == 'ta' ? shopNameTa : shopName,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(lang == 'ta' ? addressTa : address),
                  const SizedBox(height: 8),
                  Text(t('Phone', 'தொலைபேசி') + ': $phone'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _call,
                  icon: const Icon(Icons.call),
                  label: Text(t('Call', 'அழைக்க')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _whatsapp,
                  icon: const Icon(Icons.chat),
                  label: Text(t('WhatsApp', 'வாட்ஸ்அப்')), 
                ),
              ),
            ],
          )
        ],
      ),
    );

    if (!embedInScaffold) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Contact Us', 'தொடர்பு கொள்ள')),
        leading: backOrHomeButton(context),
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
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}
