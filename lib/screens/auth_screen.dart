import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/progress_bar.dart';

/// Mobile + DEMO OTP login. The demo OTP (123456) is shown on screen.
/// No real SMS is sent — this is labelled DEMO throughout.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = AuthService();
  bool _otpSent = false;
  bool _busy = false;
  String? _error;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10 || int.tryParse(phone) == null) {
      setState(() => _error = 'Enter a valid 10-digit mobile number.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await _auth.requestOtp(phone);
    setState(() {
      _busy = false;
      _otpSent = true;
    });
  }

  Future<void> _verify() async {
    final phone = _phoneController.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final user = await _auth.verifyOtp(
      phone: phone,
      otp: _otpController.text.trim(),
    );
    setState(() => _busy = false);
    if (!mounted) return;
    if (user != null) {
      context.read<AppState>().setUser(user);
      Navigator.pushReplacementNamed(context, '/home');
    } else if (_otpController.text.trim() != AuthService.demoOtp) {
      setState(() => _error = 'Wrong demo OTP. Use 123456.');
    } else {
      // New user — go to registration.
      Navigator.pushNamed(context, '/register', arguments: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DemoBanner(
              text: 'DEMO LOGIN — no real SMS is sent. Demo OTP is 123456.',
            ),
            const SizedBox(height: 20),
            const Text(
              'DONEXIA',
              style: TextStyle(
                color: DonexiaTheme.muted,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            Text(
              'लॉगिन / रजिस्ट्रेशन',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                prefixText: '+91 ',
                labelText: 'Mobile number',
                hintText: '9876543210',
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Demo OTP',
                  hintText: '123456',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demo OTP: 123456 (shown here because no SMS is sent)',
                style: TextStyle(fontSize: 12, color: DonexiaTheme.muted),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: DonexiaTheme.error)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : (_otpSent ? _verify : _sendOtp),
              child: _busy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_otpSent ? 'Verify OTP' : 'Send OTP (Demo)'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Demo admin: phone 9999999999 + OTP 123456 → opens Admin Panel.',
              style: TextStyle(fontSize: 12, color: DonexiaTheme.muted),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _phoneController.text = AuthService.demoAdminPhone;
                _otpController.text = AuthService.demoOtp;
                setState(() => _otpSent = true);
              },
              child: const Text('Fill demo admin credentials'),
            ),
          ],
        ),
      ),
    );
  }
}
