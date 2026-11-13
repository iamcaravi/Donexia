import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'screens/admin_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/create_campaign_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'utils/theme.dart';

/// Donexia — A Small Help. A Big Difference.
/// Flutter MVP: local demo data only, demo OTP, demo payments.
/// No backend, no real SMS, no real money.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const DonexiaApp(),
    ),
  );
}

class DonexiaApp extends StatelessWidget {
  const DonexiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'Donexia',
          debugShowCheckedModeBanner: false,
          theme: DonexiaTheme.light(),
          locale: state.locale,
          supportedLocales: const [Locale('en'), Locale('hi')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/auth': (_) => const AuthScreen(),
            '/register': (_) => const RegisterScreen(),
            '/home': (_) => const HomeScreen(),
            '/explore': (_) => const ExploreScreen(),
            '/create-campaign': (_) => const CreateCampaignScreen(),
            '/admin': (_) => const AdminRouteGuard(
              child: AdminScreen(),
            ),
          },
        );
      },
    );
  }
}

/// Route guard: only a logged-in admin may open /admin.
/// Anyone else is sent to /auth with a message.
class AdminRouteGuard extends StatelessWidget {
  final Widget child;
  const AdminRouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.user?.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Admin access only.\nLog in with the demo admin account:\nphone 9999999999, OTP 123456.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth'),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}
