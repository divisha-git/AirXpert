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
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _doLogin() {
    if (!_formKey.currentState!.validate()) return;

    final error = AppState.instance.login(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    if (error != null) {
      final appLang = AppLanguage.of(context);
      final lang = appLang.languageCode;
      String t(String en, String ta) => lang == 'ta' ? ta : en;

      String displayErr = error;
      if (error == 'Invalid email or password') {
        displayErr = t('Invalid email or password', 'தவறான மின்னஞ்சல் அல்லது கடவுச்சொல்');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(displayErr)),
      );
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
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "AirXpert",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Email
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: t("Email", "மின்னஞ்சல்"),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t("Email is required", "மின்னஞ்சல் தேவை");
                      }
                      if (!value.contains('@')) {
                        return t("Enter valid email", "சரியான மின்னஞ்சலை உள்ளிடவும்");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Password
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: t("Password", "கடவுச்சொல்"),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t("Password is required", "கடவுச்சொல் தேவை");
                      }
                      if (value.length < 4) {
                        return t("Minimum 4 characters", "குறைந்தது 4 எழுத்துகள்");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  /// Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _doLogin,
                      child: Text(t("Login", "உள்நுழைக")),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(t("Don't have an account? ", "கணக்கு இல்லையா? ")),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: Text(t("Sign up", "பதிவு செய்க")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
