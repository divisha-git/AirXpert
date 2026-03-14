import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final app = AppState.instance;
    _nameCtrl = TextEditingController(text: app.customerName);
    _phoneCtrl = TextEditingController(text: app.phoneNumber);
    _addressCtrl = TextEditingController(text: app.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    final app = AppState.instance;
    app.setCustomerDetails(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addr: _addressCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLanguage.of(context).languageCode == 'ta' ? 'விவரங்கள் சேமிக்கப்பட்டன' : 'Details saved')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      appBar: AppBar(title: Text(t('Customer Details', 'வாடிக்கையாளர் விவரங்கள்'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: t('Name', 'பெயர்'),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: t('Phone Number', 'தொலைபேசி எண்'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: (v) => (v == null || v.trim().length < 10) ? t('Enter valid phone', 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: t('Address', 'முகவரி'),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? t('Enter address', 'முகவரியை உள்ளிடவும்') : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(t('Save', 'சேமி')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
