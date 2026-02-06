import 'package:flutter/material.dart';

import '../main.dart';
import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  String _role = 'user'; // 'user' | 'admin'

  @override
  void initState() {
    super.initState();
    // Reset form state when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _doLogin() {
    if (_formKey.currentState?.validate() != true) return;

    final err = AppState.instance.login(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final role = AppState.instance.currentUser!.role;
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                  Text(
                    'AirXpert',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _email,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            enabled: true,
                            enableInteractiveSelection: true,
                            decoration: InputDecoration(
                              labelText: t('Email', 'மின்னஞ்சல்'),
                              prefixIcon: const Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (v) =>
                                (v == null || !v.contains('@'))
                                    ? t('Enter a valid email', 'சரியான மின்னஞ்சலை உள்ளிடவும்')
                                    : null,
                            onFieldSubmitted: (_) {
                              _emailFocus.unfocus();
                              _passwordFocus.requestFocus();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            focusNode: _passwordFocus,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            enabled: true,
                            enableInteractiveSelection: true,
                            onFieldSubmitted: (_) {
                              _passwordFocus.unfocus();
                              _doLogin();
                            },
                            decoration: InputDecoration(
                              labelText: t('Password', 'கடவுச்சொல்'),
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.length < 4)
                                    ? t('Minimum 4 characters',
                                        'குறைந்தது 4 எழுத்துகள் தேவை')
                                    : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _doLogin,
                              child: Text(t('Login', 'உள்நுழைக')),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t(
                                  "Don't have an account? ",
                                  'கணக்கு இல்லையா? ')),
                              TextButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pushReplacementNamed(
                                      context, '/signup');
                                },
                                child: Text(t('Sign up', 'புதிய கணக்கு')),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
