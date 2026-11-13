import 'dart:math';

import '../data/local_store.dart';
import '../models/user.dart';

/// DEMO OTP authentication — clearly labelled in the UI.
/// No real SMS is sent. The demo OTP is always shown on screen and is
/// also returned here so the UI can display it. Replace this service
/// with a real backend OTP flow before any production release.
class AuthService {
  static const String demoOtp = '123456';

  /// Demo admin account (see README.md). Role-gated in the app:
  /// only this login gets the Admin role.
  static const String demoAdminPhone = '9999999999';
  static const String demoAdminName = 'Donexia Admin';

  String? _pendingPhone;
  String? get pendingPhone => _pendingPhone;

  Future<String> requestOtp(String phone) async {
    _pendingPhone = phone;
    // In production: call backend / SMS provider here.
    // Demo: return the fixed OTP so the UI can show it.
    return demoOtp;
  }

  Future<AppUser?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (otp != demoOtp) return null;
    final existing = await LocalStore.loadUser();
    if (existing != null && existing.phone == phone) return existing;
    if (phone == demoAdminPhone) {
      final admin = AppUser(
        id: 'admin_demo',
        name: demoAdminName,
        phone: phone,
        state: 'Uttar Pradesh',
        district: 'Kanpur Nagar',
        roles: {UserRole.admin, UserRole.donor},
        termsAccepted: true,
        createdAt: DateTime.now(),
      );
      await LocalStore.saveUser(admin);
      return admin;
    }
    // New user — registration screen completes the profile.
    return null;
  }

  Future<AppUser> register({
    required String phone,
    required String name,
    String? email,
    required String state,
    required String district,
    String? photoPath,
  }) async {
    final user = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      state: state,
      district: district,
      photoPath: photoPath,
      roles: {UserRole.donor, UserRole.helpSeeker},
      termsAccepted: true,
      createdAt: DateTime.now(),
    );
    await LocalStore.saveUser(user);
    return user;
  }

  Future<void> logout() => LocalStore.clearUser();

  String generateReceiptSuffix() =>
      Random().nextInt(90000).toString().padLeft(5, '0');
}
