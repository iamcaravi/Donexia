import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bank.dart';
import '../models/campaign.dart';
import '../models/user.dart';
import 'seed_data.dart';

/// Local-only persistence (SharedPreferences JSON).
/// No backend, no network calls. Demo data is seeded on first launch.
/// Payment details are never stored in a public campaign record.
class LocalStore {
  static const _kCampaigns = 'donexia_campaigns_v1';
  static const _kDonations = 'donexia_donations_v1';
  static const _kBanks = 'donexia_banks_v1';
  static const _kUser = 'donexia_user_v1';
  static const _kOnboarded = 'donexia_onboarded_v1';
  static const _kSeeded = 'donexia_seeded_v1';

  static Future<void> ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeeded) == true) return;
    final campaigns = seedCampaigns();
    await prefs.setString(
      _kCampaigns,
      jsonEncode(campaigns.map((c) => c.toJson()).toList()),
    );
    await prefs.setString(
      _kBanks,
      jsonEncode(defaultBanks().map((b) => b.toJson()).toList()),
    );
    await prefs.setString(_kDonations, jsonEncode([]));
    await prefs.setBool(_kSeeded, true);
  }

  static Future<List<Campaign>> loadCampaigns() async {
    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCampaigns);
    if (raw == null) return seedCampaigns();
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveCampaigns(List<Campaign> campaigns) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kCampaigns,
      jsonEncode(campaigns.map((c) => c.toJson()).toList()),
    );
  }

  static Future<void> upsertCampaign(Campaign campaign) async {
    final all = await loadCampaigns();
    final idx = all.indexWhere((c) => c.id == campaign.id);
    if (idx >= 0) {
      all[idx] = campaign;
    } else {
      all.insert(0, campaign);
    }
    await saveCampaigns(all);
  }

  static Future<List<Donation>> loadDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDonations);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Donation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addDonation(Donation donation) async {
    final all = await loadDonations();
    all.insert(0, donation);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kDonations,
      jsonEncode(all.map((d) => d.toJson()).toList()),
    );
    // Apply the donation to the campaign totals (demo only).
    final campaigns = await loadCampaigns();
    final idx = campaigns.indexWhere((c) => c.id == donation.campaignId);
    if (idx >= 0) {
      campaigns[idx] = campaigns[idx].copyWith(
        raisedAmount:
            campaigns[idx].raisedAmount + donation.beneficiaryAmount,
        donorCount: campaigns[idx].donorCount + 1,
      );
      await saveCampaigns(campaigns);
    }
  }

  static Future<List<Bank>> loadBanks() async {
    await ensureSeeded();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBanks);
    if (raw == null) return defaultBanks();
    final list = jsonDecode(raw) as List;
    return list.map((e) => Bank.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveBanks(List<Bank> banks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kBanks,
      jsonEncode(banks.map((b) => b.toJson()).toList()),
    );
  }

  static Future<AppUser?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUser);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUser);
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarded) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, true);
  }

  static Future<void> resetDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSeeded);
    await prefs.remove(_kCampaigns);
    await prefs.remove(_kDonations);
    await prefs.remove(_kBanks);
    await ensureSeeded();
  }
}
