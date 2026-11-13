import 'package:donexia/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1% platform fee', () {
    expect(Donation.feeFor(100), 1.0);
    expect(Donation.feeFor(1000), 10.0);
    expect(Donation.feeFor(50), 0.5);
    expect(Donation.feeFor(10), 0.1);
  });

  test('donation splits fee and beneficiary amount', () {
    final d = Donation.create(
      campaignId: 'cmp_001',
      campaignTitle: 'Test',
      donorName: 'Tester',
      amount: 1000,
      method: 'UPI (Demo)',
    );
    expect(d.platformFee, 10.0);
    expect(d.beneficiaryAmount, 990.0);
    expect(d.receiptId.startsWith('DNX'), true);
  });
}
