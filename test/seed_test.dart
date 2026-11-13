import 'package:donexia/data/seed_data.dart';
import 'package:donexia/models/campaign.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed has at least 8 campaigns with the SBI loan example', () {
    final campaigns = seedCampaigns();
    expect(campaigns.length, greaterThanOrEqualTo(8));
    final loan = campaigns.firstWhere(
      (c) => c.id == 'cmp_001',
      orElse: () => throw StateError('cmp_001 missing'),
    );
    expect(loan.targetAmount, 240000);
    expect(loan.category, CampaignCategory.loan);
    expect(loan.city, 'Kanpur');
    for (final c in campaigns) {
      expect(c.targetAmount, greaterThan(0));
      expect(c.progress, inInclusiveRange(0, 1));
    }
  });
}
