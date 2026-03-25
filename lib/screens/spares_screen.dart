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
    final appLang = AppLanguage.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final lang = appLang.languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final spares = app.spares.toList();
        
        Widget content;
        if (spares.isEmpty) {
          content = Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    t('No spares added yet', 'பொருட்கள் சேர்க்கப்படவில்லை'),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          content = Material(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              itemCount: spares.length,
              itemBuilder: (context, index) {
                final s = spares[index];
                return _SpareCard(
                  spare: s,
                  langCode: lang,
                );
              },
            ),
          );
        }

        if (!embedInScaffold) return content;

        return Scaffold(
          appBar: AppBar(
            title: Text(t('Spare Parts', 'ஸ்பேர் பாகங்கள்')),
            leading: backOrHomeButton(context),
            actions: [
              ListenableBuilder(
                listenable: app,
                builder: (context, _) {
                  final cartCount = app.cartCount;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () => Navigator.pushNamed(context, '/cart'),
                      ),
                      if (cartCount > 0)
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
                              '$cartCount',
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
          body: content,
        );
      },
    );
  }
}

class _SpareCard extends StatelessWidget {
  final SparePart spare;
  final String langCode;

  const _SpareCard({required this.spare, required this.langCode});

  String t(String en, String ta) => langCode == 'ta' ? ta : en;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = t(spare.name, spare.nameTa);
    final displayDesc = t(spare.description, spare.descriptionTa);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _renderSpareImage(spare.imageUrl),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            displayDesc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '₹${spare.price.toStringAsFixed(0)}',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: colorScheme.primary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 32),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!spare.inStock)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      t('Out of Stock', 'ஸ்டாக் இல்லை'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: spare.inStock ? colorScheme.primary : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  onPressed: spare.inStock
                      ? () {
                          AppState.instance.addToCart(CartItem(
                            id: spare.id,
                            name: spare.name,
                            nameTa: spare.nameTa,
                            price: spare.price,
                            type: 'spare',
                            imageUrl: spare.imageUrl,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t('Added to cart', 'கார்டில் சேர்க்கப்பட்டது')),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: t('View', 'காண்க'),
                                onPressed: () => Navigator.pushNamed(context, '/cart'),
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _renderSpareImage(String url) {
  if (url.isEmpty) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
    );
  }
  if (url.startsWith('data:image')) {
    try {
      final base64Data = url.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
      );
    }
  }
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
      );
    },
  );
}
