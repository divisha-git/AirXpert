import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../main.dart';

class BillingScreen extends StatefulWidget {
  final bool embedInScaffold;

  const BillingScreen({super.key, this.embedInScaffold = true});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late final String _billNo;
  late final String _dateStr;

  @override
  void initState() {
    super.initState();
    _billNo = AppState.instance.generateBillNumber();
    final now = DateTime.now();
    _dateStr = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    // Language helper
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    String typeTa(String type) {
      if (lang != 'ta') return type.toUpperCase();
      switch (type) {
        case 'product':
          return 'பொருள்';
        case 'spare':
          return 'ஸ்பேர் பாகம்';
        case 'service':
          return 'சேவை';
        default:
          return type.toUpperCase();
      }
    }

    Widget body = Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Bill No', 'பில் எண்') + ': $_billNo',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(t('Date', 'தேதி') + ': $_dateStr'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Customer Details', 'வாடிக்கையாளர் விவரங்கள்'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(t('Name', 'பெயர்') + ': ${app.customerName.isEmpty ? '-' : app.customerName}'),
                  Text(t('Phone', 'தொலைபேசி') + ': ${app.phoneNumber.isEmpty ? '-' : app.phoneNumber}'),
                  Text(t('Address', 'முகவரி') + ': ${app.address.isEmpty ? '-' : app.address}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Items', 'பொருட்கள்/உருப்படிகள்'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (app.billItems.isEmpty)
                    Text(t('No items added yet', 'இன்னும் உருப்படிகள் இல்லை'))
                  else
                    ...app.billItems.map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(typeTa(item.type)),
                        trailing:
                            Text('₹${item.price.toStringAsFixed(2)}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              t('Total', 'மொத்தம்') + ': ₹${app.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      app.clearBill();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Bill cleared (temporary memory only)', 'பில் நீக்கப்பட்டது (தற்காலிக நினைவகம் மட்டும்)'))));
                  },
                  child: Text(t('Clear Bill', 'பில் நீக்கு')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Bill generated (display only, not saved)', 'பில் உருவாக்கப்பட்டது (காட்சி மட்டும், சேமிக்கப்படாது)'))));
                  },
                  child: Text(t('Generate Bill', 'பில் உருவாக்கு')),
                ),
              ),
            ],
          )
        ],
      ),
    );

    if (!widget.embedInScaffold) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Billing', 'பில்')),
        leading: backOrHomeButton(context),
      ),
      body: body,
    );
  }
}
