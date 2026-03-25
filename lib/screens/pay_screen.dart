import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../state/app_state.dart';
import '../main.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final app = AppState.instance;
    final total = app.cartTotal;
    
    // Show a global loading indicator or just rely on state
    setState(() => _isProcessing = true);

    await app.addPayment(total, 'Razorpay');
    final order = await app.placeOrderFromCart(status: 'paid');
    
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('Payment success. Order #', 'கட்டணம் வெற்றி. ஆர்டர் #') + order.id),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => r.settings.name == '/home');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('Payment failed: ', 'கட்டணம் தோல்வியடைந்தது: ') + (response.message ?? 'Unknown error')),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    // Handle external wallet
  }

  void _openCheckout() {
    setState(() => _isProcessing = true);
    final app = AppState.instance;
    final user = app.currentUser;
    final amount = (app.cartTotal * 100).toInt(); // Razorpay expects amount in paise

    if (app.razorpayKey == 'rzp_test_YOUR_KEY_HERE' || app.razorpayKey.isEmpty) {
      setState(() => _isProcessing = false);
      final lang = AppLanguage.of(context).languageCode;
      String t(String en, String ta) => lang == 'ta' ? ta : en;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(
            'Please configure your Razorpay Key ID in AppState.',
            'தயவுசெய்து AppState-ல் உங்கள் Razorpay Key ID-ஐ உள்ளமைக்கவும்.'
          )),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    var options = {
      'key': app.razorpayKey,
      'amount': amount,
      'name': 'AirXpert',
      'description': 'AC Sales & Service',
      'prefill': {
        'contact': app.phoneNumber,
        'email': user?.email ?? '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.of(context).languageCode;
    String t(String en, String ta) => lang == 'ta' ? ta : en;
    final amount = AppState.instance.cartTotal.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Payment Checkout', 'பணம் செலுத்துதல்')),
        leading: backOrHomeButton(context),
        actions: [
          ListenableBuilder(
            listenable: AppState.instance,
            builder: (context, _) {
              final count = AppState.instance.cartCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  if (count > 0)
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
                          '$count',
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 24),
            Text(
              t('Order Summary', 'ஆர்டர் சுருக்கம்'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t('Total Amount', 'மொத்த தொகை') + ': '),
                Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isProcessing ? null : _openCheckout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    t('Pay with Razorpay', 'Razorpay மூலம் செலுத்தவும்'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              t('Secure payments powered by Razorpay', 'Razorpay மூலம் பாதுகாப்பான கட்டணங்கள்'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
