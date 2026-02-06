import 'package:flutter/material.dart';
import '../main.dart';
import '../models/item.dart';
import '../state/app_state.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  Map<String, dynamic>? _selectedService;
  String _acType = 'Split'; // 'Split' | 'Window' | 'Cassette' | 'Portable'
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;

  String _translateServiceName(String en, String lang) {
    if (lang != 'ta') return en;
    final translations = {
      'AC Installation': 'ஏசி நிறுவல்',
      'AC Repair': 'ஏசி சரிசெய்தல்',
      'AC Gas Filling': 'ஏசி எரிவாயு நிரப்புதல்',
      'AC General Service': 'ஏசி பொது சேவை',
      'Washing Machine Repair': 'கழுவி இயந்திரம் சரிசெய்தல்',
    };
    return translations[en] ?? en;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true || _selectedService == null || _preferredDate == null || _preferredTime == null) {
      final appLang = AppLanguage.of(context);
      final lang = appLang.languageCode;
      String t(String en, String ta) => lang == 'ta' ? ta : en;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('Please fill all fields, select a service, date and time', 'தயவுசெய்து அனைத்து புலங்களையும் நிரப்பி சேவை, தேதி மற்றும் நேரத்தைத் தேர்ந்தெடுக்கவும்'))),
      );
      return;
    }
    AppState.instance.setCustomerDetails(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addr: _addressController.text.trim(),
    );
    AppState.instance.addBillItem(
      BillItem(
        name: _selectedService!['name'],
        price: _selectedService!['price'],
        type: 'service',
      ),
    );

    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('Booking Confirmed', 'பதிவு உறுதிப்படுத்தப்பட்டது')),
        content: Text(
          t(
            'Your service has been added to the bill. Preferred: ',
            'உங்கள் சேவை பிலில் சேர்க்கப்பட்டது. விரும்பிய நேரம்: ',
          ) +
              '${_preferredDate!.day.toString().padLeft(2, '0')}-${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.year} ' +
              '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}\n' +
              t('AC Type: ', 'ஏசி வகை: ') + _acType +
              ( _problemController.text.trim().isEmpty ? '' : '\n' + t('Problem: ', 'பிரச்சனை: ') + _problemController.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(t('OK', 'சரி')),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;
    final app = AppState.instance;
    final services = app.services;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Book Service', 'சேவை பதிவு')),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: t('Customer Name', 'வாடிக்கையாளர் பெயர்'),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? t('Enter name', 'பெயரை உள்ளிடவும்') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: t('Phone Number', 'தொலைபேசி எண்'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: (v) => (v == null || v.trim().length < 10) ? t('Enter valid phone', 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: t('Address', 'முகவரி'),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? t('Enter address', 'முகவரியை உள்ளிடவும்') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: t('AC Type', 'ஏசி வகை'),
                  prefixIcon: const Icon(Icons.ac_unit_rounded),
                ),
                value: _acType,
                items: ['Split', 'Window', 'Cassette', 'Portable']
                    .map((e) => DropdownMenuItem(value: e, child: Text(t(e, e == 'Split' ? 'ஸ்ப்ளிட்' : e == 'Window' ? 'விண்டோ' : e == 'Cassette' ? 'கேஸெட்' : 'போர்டபுள்'))))
                    .toList(),
                onChanged: (v) => setState(() => _acType = v ?? 'Split'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _problemController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: t('Problem description (optional)', 'பிரச்சனை விவரம் (விருப்பத் தேர்வு)'),
                  prefixIcon: const Icon(Icons.report_problem_outlined),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceType>(
                decoration: InputDecoration(
                  labelText: t('Service Type', 'சேவை வகை'),
                  prefixIcon: const Icon(Icons.build_outlined),
                ),
                value: null,
                items: services.map((s) {
                  final nameEn = s.name;
                  final nameTa = _translateServiceName(nameEn, lang);
                  return DropdownMenuItem(
                    value: s,
                    child: Text('${lang == 'ta' ? nameTa : nameEn} - ₹${s.price.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedService = {
                        'name': lang == 'ta' ? _translateServiceName(val.name, lang) : val.name,
                        'price': val.price,
                      };
                    });
                  }
                },
                hint: Text(t('Select a service', 'சேவையைத் தேர்ந்தெடுக்கவும்')),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 30)),
                          initialDate: _preferredDate ?? now,
                        );
                        if (picked != null) setState(() => _preferredDate = picked);
                      },
                      icon: const Icon(Icons.event_rounded),
                      label: Text(_preferredDate == null
                          ? t('Pick date', 'தேதியைத் தேர்ந்தெடுக்கவும்')
                          : '${_preferredDate!.day.toString().padLeft(2, '0')}-${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.year}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _preferredTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _preferredTime = picked);
                      },
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(_preferredTime == null
                          ? t('Pick time', 'நேரத்தைத் தேர்ந்தெடுக்கவும்')
                          : '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(t('Submit', 'சமர்ப்பிக்க')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
