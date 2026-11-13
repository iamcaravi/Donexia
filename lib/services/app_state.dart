import 'package:material_ui/material_ui.dart';

import '../data/local_store.dart';
import '../models/bank.dart';
import '../models/campaign.dart';
import '../models/user.dart';

/// App-wide state (Provider ChangeNotifier): current user, campaigns,
/// donations, banks, locale and filters. All data is local/demo.
class AppState extends ChangeNotifier {
  AppUser? user;
  List<Campaign> campaigns = [];
  List<Donation> donations = [];
  List<Bank> banks = [];
  Locale locale = const Locale('en');
  bool loaded = false;

  Future<void> init() async {
    await LocalStore.ensureSeeded();
    user = await LocalStore.loadUser();
    campaigns = await LocalStore.loadCampaigns();
    donations = await LocalStore.loadDonations();
    banks = await LocalStore.loadBanks();
    loaded = true;
    notifyListeners();
  }

  void setUser(AppUser? u) {
    user = u;
    notifyListeners();
  }

  void setLocale(Locale l) {
    locale = l;
    notifyListeners();
  }

  void toggleLocale() {
    locale = locale.languageCode == 'en'
        ? const Locale('hi')
        : const Locale('en');
    notifyListeners();
  }

  List<Campaign> get publicCampaigns =>
      campaigns.where((c) => c.status.isPublic).toList();

  List<Campaign> get pendingCampaigns =>
      campaigns
          .where(
            (c) =>
                c.status == CampaignStatus.pending ||
                c.status == CampaignStatus.moreInfo,
          )
          .toList();

  double get totalRaised =>
      campaigns.fold(0, (sum, c) => sum + c.raisedAmount);
  int get totalDonors =>
      campaigns.fold(0, (sum, c) => sum + c.donorCount);
  int get totalBeneficiaries => publicCampaigns.length;

  List<Campaign> filtered({
    CampaignCategory? category,
    String query = '',
    String? state,
    String? district,
    bool verifiedOnly = false,
    String sort = 'recent',
  }) {
    var list = publicCampaigns;
    if (category != null) {
      list = list.where((c) => c.category == category).toList();
    }
    if (state != null && state.isNotEmpty) {
      list = list.where((c) => c.state == state).toList();
    }
    if (district != null && district.isNotEmpty) {
      list = list.where((c) => c.district == district).toList();
    }
    if (verifiedOnly) list = list.where((c) => c.verified).toList();
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where(
            (c) =>
                c.title.toLowerCase().contains(q) ||
                c.beneficiaryName.toLowerCase().contains(q) ||
                c.city.toLowerCase().contains(q),
          )
          .toList();
    }
    switch (sort) {
      case 'mostNeeded':
        list.sort((a, b) => a.progress.compareTo(b.progress));
      case 'mostRaised':
        list.sort((a, b) => b.raisedAmount.compareTo(a.raisedAmount));
      case 'recent':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  Future<void> addDonation(Donation d) async {
    await LocalStore.addDonation(d);
    donations = await LocalStore.loadDonations();
    campaigns = await LocalStore.loadCampaigns();
    notifyListeners();
  }

  Future<void> submitCampaign(Campaign c) async {
    await LocalStore.upsertCampaign(c);
    campaigns = await LocalStore.loadCampaigns();
    notifyListeners();
  }

  Future<void> setCampaignStatus(
    String id,
    CampaignStatus status, {
    String? reason,
  }) async {
    final idx = campaigns.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    campaigns[idx] = campaigns[idx].copyWith(
      status: status,
      rejectionReason: reason,
    );
    await LocalStore.saveCampaigns(campaigns);
    notifyListeners();
  }

  Future<void> saveBanks(List<Bank> next) async {
    banks = next;
    await LocalStore.saveBanks(next);
    notifyListeners();
  }
}
