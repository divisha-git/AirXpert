import 'package:flutter/material.dart';
import 'dart:convert';

import '../main.dart';
import '../models/item.dart';
import '../state/app_state.dart';

class SparesScreen extends StatelessWidget {
  final bool embedInScaffold;

  const SparesScreen({super.key, this.embedInScaffold = true});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final spares = app.spares;
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    String _nameTa(String id, String fallback) {
      if (lang != 'ta') return fallback;
      switch (id) {
        case 's1':
          return 'ஏசி கம்ப்ரசர்';
        case 's2':
          return 'வெளிப்புற பான் மோட்டார்';
        default:
          return fallback;
      }
    }

    String _descTa(String id, String fallback) {
      if (lang != 'ta') return fallback;
      switch (id) {
        case 's1':
          return '1.5 டன் யூனிட்களுக்கு அசல் ரோட்டரி கம்ப்ரசர்.';
        case 's2':
          return 'ஸ்ப்ளிட் ஏசி வெளிப்புற யூனிட்களுக்கு திடமான பான் மோட்டார்.';
        default:
          return fallback;
      }
    }

    Widget content = spares.isEmpty
        ? Center(child: Text(t('No spares added yet', 'ஸ்பேர் பாகங்கள் சேர்க்கப்படவில்லை')))
        : GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: spares.length,
      itemBuilder: (context, index) {
        final SparePart s = spares[index];
        return _SpareCard(
          spare: s,
          langCode: lang,
          nameTa: _nameTa(s.id, s.name),
          descTa: _descTa(s.id, s.description),
        );
      },
    );

    if (!embedInScaffold) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('AC Spare Parts', 'ஏசி ஸ்பேர் பாகங்கள்')),
        leading: backOrHomeButton(context),
      ),
      body: content,
    );
  }
}

class _SpareCard extends StatelessWidget {
  final SparePart spare;
  final String langCode;
  final String nameTa;
  final String descTa;

  const _SpareCard({required this.spare, required this.langCode, required this.nameTa, required this.descTa});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = langCode == 'ta' ? nameTa : spare.name;
    final displayDesc = langCode == 'ta' ? descTa : spare.description;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _renderSpareImage(spare.imageUrl)),
                if (!spare.inStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t('Out of Stock', 'ஸ்டாக் இல்லை'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      displayDesc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '₹${spare.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        AppState.instance.addToCart(
                          CartItem(
                            id: spare.id,
                            name: displayName,
                            price: spare.price,
                            type: 'spare',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              t(
                                '${displayName} added to cart',
                                '${displayName} கார்டில் சேர்க்கப்பட்டது',
                              ),
                            ),
                            duration: const Duration(seconds: 1),
                            action: SnackBarAction(
                              label: t('View', 'காண்க'),
                              onPressed: () => Navigator.pushNamed(context, '/cart'),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _renderSpareImage(String url) {
  if (url.startsWith('data:image')) {
    final base64Data = url.split(',').last;
    final bytes = base64Decode(base64Data);
    return Image.memory(bytes, fit: BoxFit.cover);
  }
  return Image.network(url, fit: BoxFit.cover);
}
