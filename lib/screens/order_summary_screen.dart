import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  bool _needInstallation = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    final app = AppState.instance;
    final items = app.cartItems;
    final subtotal = app.cartTotal;
    final installFee = _needInstallation ? 999.0 : 0.0;
    final total = subtotal + installFee;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Order Summary', 'ஆர்டர் சுருக்கம்')),
        leading: backOrHomeButton(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('Items', 'உருப்படிகள்'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...items.map((c) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(c.name),
                            trailing: Text('₹${(c.price * c.quantity).toStringAsFixed(2)}'),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('Delivery Address', 'டெலிவரி முகவரி'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(hintText: t('Enter full address', 'முழு முகவரியை உள்ளிடவும்')),
                        validator: (v) => (v == null || v.trim().isEmpty) ? t('Address required', 'முகவரி தேவை') : null,
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _needInstallation,
                        onChanged: (v) => setState(() => _needInstallation = v ?? false),
                        title: Text(t('Need installation (₹999)', 'நிறுவல் தேவை (₹999)')),
                        controlAffinity: ListTileControlAffinity.leading,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _totalRow(context, t('Subtotal', 'கூட்டுத்தொகை'), subtotal),
                      _totalRow(context, t('Installation', 'நிறுவல்'), installFee),
                      const Divider(),
                      _totalRow(context, t('Total', 'மொத்தம்'), total, bold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) return;
                    app.setCustomerDetails(name: app.customerName, phone: app.phoneNumber, addr: _addressCtrl.text.trim());
                    Navigator.pushNamed(context, '/pay');
                  },
                  child: Text(t('Proceed to Payment', 'கட்டணத்திற்கு செல்லவும்')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalRow(BuildContext context, String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.w700) : null),
          Text('₹${value.toStringAsFixed(2)}', style: bold ? const TextStyle(fontWeight: FontWeight.w700) : null),
        ],
      ),
    );
  }
}
