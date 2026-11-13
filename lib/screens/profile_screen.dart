import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/local_store.dart';
import '../models/user.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user == null)
            const Text('Not logged in.')
          else ...[
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Text(
                user.name.isEmpty ? '?' : user.name[0],
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Center(child: Text('+91 ${user.phone}')),
            Center(
              child: Text('${user.district}, ${user.state}'),
            ),
            Center(
              child: Chip(
                label: Text(
                  user.roles.map((r) => r.label).join(' • '),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language — हिंदी / English'),
            trailing: Text(state.locale.languageCode == 'hi' ? 'हिंदी' : 'English'),
            onTap: state.toggleLocale,
          ),
          if (user?.isAdmin == true)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Panel'),
              onTap: () => Navigator.pushNamed(context, '/admin'),
            ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reset demo data'),
            subtitle: const Text('Restore the 10 seed campaigns'),
            onTap: () async {
              await LocalStore.resetDemoData();
              await state.init();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo data reset.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().logout();
              state.setUser(null);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth',
                  (_) => false,
                );
              }
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Donexia v1.0.0 (demo) — A Small Help. A Big Difference.\nNo backend. No real payments. Demo OTP only.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
