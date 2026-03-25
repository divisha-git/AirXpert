import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String _role = 'user';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _doSignup() async {
    if (_formKey.currentState?.validate() != true) return;

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final err = await AppState.instance.signup(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      role: _role,
    );

    if (!mounted) return;
    Navigator.pop(context); // Remove loading dialog

    if (err != null) {
      final appLang = AppLanguage.of(context);
      final lang = appLang.languageCode;
      String t(String en, String ta) => lang == 'ta' ? ta : en;

      String displayErr = err;
      if (err == 'User already exists') {
        displayErr = t('User already exists', 'பயனர் ஏற்கனவே உள்ளார்');
      } else if (err == 'Invalid role') {
        displayErr = t('Invalid role', 'தவறான பங்கு');
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(displayErr)));
      return;
    }

    AppState.instance.login(
      email: _email.text.trim(),
      password: _password.text,
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      _role == 'admin' ? '/admin' : '/user',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final lang = appLang.languageCode;

    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'AirXpert',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _name,
                                    focusNode: _nameFocus,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: t('Name', 'பெயர்'),
                                      prefixIcon: const Icon(
                                          Icons.person_outline_rounded),
                                    ),
                                    validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? t('Enter name',
                                        'பெயரை உள்ளிடவும்')
                                        : null,
                                    onFieldSubmitted: (_) {
                                      _nameFocus.unfocus();
                                      _emailFocus.requestFocus();
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _email,
                                    focusNode: _emailFocus,
                                    keyboardType:
                                    TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: t('Email', 'மின்னஞ்சல்'),
                                      prefixIcon: const Icon(
                                          Icons.mail_outline_rounded),
                                    ),
                                    validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? t('Enter valid email',
                                        'சரியான மின்னஞ்சல்')
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
                                    decoration: InputDecoration(
                                      labelText:
                                      t('Password', 'கடவுச்சொல்'),
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscure
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded),
                                        onPressed: () => setState(
                                                () => _obscure = !_obscure),
                                      ),
                                    ),
                                    validator: (v) =>
                                    (v == null || v.length < 4)
                                        ? t('Minimum 4 characters',
                                        'குறைந்தது 4 எழுத்துகள்')
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _role,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: t('Role', 'பங்கு'),
                                      prefixIcon: const Icon(
                                          Icons.person_outline_rounded),
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'user',
                                        child: Text(
                                          t('Customer', 'வாடிக்கையாளர்'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'admin',
                                        child: Text(
                                          t('Shop Owner', 'கடை உரிமையாளர்'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _role = v ?? 'user'),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _doSignup,
                                    child:
                                    Text(t('Sign Up', 'பதிவு செய்க')),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(t('Already have an account? ',
                                          'ஏற்கனவே கணக்கு உள்ளதா? ')),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/login');
                                        },
                                        child: Text(t('Login', 'உள்நுழைக')),
                                      ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
