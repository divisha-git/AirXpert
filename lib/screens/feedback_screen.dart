import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../main.dart';

class FeedbackScreen extends StatefulWidget {
  final bool embedInScaffold;
  const FeedbackScreen({super.key, this.embedInScaffold = true});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _message = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    Widget body = Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              t('Share your feedback', 'உங்கள் கருத்தை பகிரவும்'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _message,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: t('Message', 'செய்தி'),
                hintText: t('Tell us what you think', 'உங்கள் கருத்தை எழுதவும்'),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? t('Required', 'தேவை') : null,
            ),
            const SizedBox(height: 12),
            Text(t('Rating', 'மதிப்பீடு')),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => setState(() => _rating = i + 1),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  AppState.instance.addFeedback(message: _message.text.trim(), rating: _rating);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Thanks for your feedback', 'உங்கள் கருத்துக்கு நன்றி'))));
                  _message.clear();
                  setState(() => _rating = 5);
                },
                child: Text(t('Submit', 'சமர்ப்பிக்க')),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.embedInScaffold) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Feedback', 'கருத்து')),
        leading: backOrHomeButton(context),
      ),
      body: body,
    );
  }
}
