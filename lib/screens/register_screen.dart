import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  String _state = 'Uttar Pradesh';
  String _district = 'Kanpur Nagar';
  bool _terms = false;
  String? _error;

  static const states = ['Uttar Pradesh', 'Delhi', 'Bihar', 'Maharashtra'];
  static const districts = [
    'Kanpur Nagar',
    'Lucknow',
    'Varanasi',
    'Agra',
    'Gorakhpur',
    'Prayagraj',
    'Jhansi',
  ];

  Future<void> _submit(String phone) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_terms) {
      setState(() => _error = 'Please accept Terms & Privacy Policy.');
      return;
    }
    final user = await AuthService().register(
      phone: phone,
      name: _name.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      state: _state,
      district: _district,
    );
    if (!mounted) return;
    context.read<AppState>().setUser(user);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Create your profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Mobile: +91 $phone'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _state,
              decoration: const InputDecoration(labelText: 'State *'),
              items: states
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _state = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _district,
              decoration: const InputDecoration(labelText: 'District *'),
              items: districts
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _district = v!),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // image_picker wired in a real build; demo keeps it optional.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Profile photo is optional in this demo build.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.photo_camera),
              label: const Text('Add profile photo (optional)'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _terms,
              onChanged: (v) => setState(() => _terms = v ?? false),
              title: const Text('I agree to the Terms & Privacy Policy'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _submit(phone),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
