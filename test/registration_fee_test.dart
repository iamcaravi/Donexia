import 'package:donexia/data/seed_data.dart';
import 'package:donexia/models/campaign.dart';
import 'package:flutter_test/flutter_test.dart';

Campaign _campaignFor(CampaignCategory category) => Campaign(
  id: 'cmp_test_${category.name}',
  title: 'Test ${category.name} campaign',
  beneficiaryName: 'Tester',
  city: 'Kanpur',
  state: 'Uttar Pradesh',
  district: 'Kanpur Nagar',
  category: category,
  status: CampaignStatus.pending,
  verified: false,
  targetAmount: 100000,
  raisedAmount: 0,
  donorCount: 0,
  story: 'Test story',
  imageUrl: '',
  createdAt: DateTime(2026, 11, 14),
  daysLeft: 30,
);

Campaign _paidCampaign() => _campaignFor(CampaignCategory.loan).copyWith(
  registrationFeePaid: true,
  registrationFeeAmount: Campaign.registrationFee,
  registrationTxnId: 'DNXRF20261114-12345',
);

void main() {
  test('registration fee is ₹99', () {
    expect(Campaign.registrationFee, 99);
  });

  test('fee applies to loan, education and emergency — not medical', () {
    expect(CampaignCategory.loan.requiresRegistrationFee, true);
    expect(CampaignCategory.education.requiresRegistrationFee, true);
    expect(CampaignCategory.emergency.requiresRegistrationFee, true);
    expect(CampaignCategory.medical.requiresRegistrationFee, false);
  });

  test('campaigns default to no fee until paid', () {
    for (final category in CampaignCategory.values) {
      final c = _campaignFor(category);
      expect(c.registrationFeePaid, false);
      expect(c.registrationFeeAmount, 0);
      expect(c.registrationTxnId, null);
    }
  });

  test('fee fields survive a JSON round-trip (local store)', () {
    final restored = Campaign.fromJson(_paidCampaign().toJson());
    expect(restored.registrationFeePaid, true);
    expect(restored.registrationFeeAmount, 99);
    expect(restored.registrationTxnId, 'DNXRF20261114-12345');
  });

  test('old stored campaigns without fee fields still load', () {
    final json = _paidCampaign().toJson()
      ..remove('registrationFeePaid')
      ..remove('registrationFeeAmount')
      ..remove('registrationTxnId');
    final restored = Campaign.fromJson(json);
    expect(restored.registrationFeePaid, false);
    expect(restored.registrationFeeAmount, 0);
    expect(restored.registrationTxnId, null);
  });

  test('seeded fee-paying campaigns are grandfathered as fee-paid', () {
    final seeds = seedCampaigns();
    final feeCategories = [
      CampaignCategory.loan,
      CampaignCategory.education,
      CampaignCategory.emergency,
    ];
    final feeSeeds = seeds
        .where((c) => feeCategories.contains(c.category))
        .toList();
    expect(feeSeeds.length, 7);
    for (final c in feeSeeds) {
      expect(c.registrationFeePaid, true, reason: c.id);
      expect(c.registrationFeeAmount, 99, reason: c.id);
      expect(c.registrationTxnId, isNotNull, reason: c.id);
    }
    // Seeded Medical campaigns are free — no fee.
    final medical = seeds
        .where((c) => c.category == CampaignCategory.medical)
        .toList();
    expect(medical.length, 3);
    for (final c in medical) {
      expect(c.registrationFeePaid, false, reason: c.id);
      expect(c.registrationFeeAmount, 0, reason: c.id);
    }
  });
}
