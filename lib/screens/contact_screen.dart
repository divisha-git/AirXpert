import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class ContactScreen extends StatelessWidget {
  final bool embedInScaffold;

  const ContactScreen({super.key, this.embedInScaffold = true});

  final String shopName = 'AirXpert AC Services';
  final String address = '123, Cooling Street, City Center, YourCity';
  final String phone = '+911234567890';

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _whatsapp() async {
    // Normalize phone for WhatsApp (digits only, no '+')
    final digits = phone.replaceAll(RegExp(r'\D'), '');
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
    final addressTa = '123, குளிர்ச்சி தெரு, நகர மையம், உங்கள் நகரம்';

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
        automaticallyImplyLeading: true,
      ),
      body: body,
    );
  }
}
