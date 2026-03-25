import 'package:flutter/material.dart';

import '../main.dart';
import '../state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  void _navigateNext() {
    if (!mounted || _navigated) return;
    _navigated = true;
    final user = AppState.instance.currentUser;
    final target = user == null
        ? '/login'
        : (user.role == 'admin' ? '/admin' : '/user');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, target);
    });
  }

  @override
  void initState() {
    super.initState();
    () async {
      final initFuture = AppState.instance.init();
      await Future.any([
        initFuture,
        Future.delayed(const Duration(seconds: 3)),
      ]);
      AppState.instance.migrateImageUrlsIfNeeded();
      if (!mounted) return;
      _navigateNext();
    }();
    Future.delayed(const Duration(seconds: 4), _navigateNext);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = AppLanguage.of(context).languageCode;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.9),
              colorScheme.primaryContainer,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(
                    Icons.ac_unit_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'AirXpert',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(
                    'AC Sales • Spares • Service',
                    'ஏசி விற்பனை • ஸ்பேர் பாகங்கள் • சேவை',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LanguageChip(label: 'EN', code: 'en'),
                    const SizedBox(width: 8),
                    _LanguageChip(label: 'தமிழ்', code: 'ta'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final String code;

  const _LanguageChip({required this.label, required this.code});

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final isSelected = appLang.languageCode == code;
    return GestureDetector(
      onTap: () => appLang.setLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 0.9 : 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.blueGrey.shade900 : Colors.white,
          ),
        ),
      ),
    );
  }
}
