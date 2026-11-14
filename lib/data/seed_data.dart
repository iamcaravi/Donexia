import '../models/campaign.dart';

/// Demo seed data — 10 realistic Indian campaigns. All amounts, names
/// and stories are fictional demo data for the MVP. No real people.
List<Campaign> seedCampaigns() {
  final now = DateTime.now();
  return [
    Campaign(
      id: 'cmp_001',
      title: 'लोन चुकाने में मदद चाहिए',
      beneficiaryName: 'Rahul Kumar',
      city: 'Kanpur',
      state: 'Uttar Pradesh',
      district: 'Kanpur Nagar',
      category: CampaignCategory.loan,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 240000,
      raisedAmount: 129600,
      donorCount: 214,
      story:
          'Rahul took a personal loan from SBI for his father\'s treatment. '
          'After losing his job, the EMIs became impossible to pay. '
          'He needs help to clear the outstanding ₹2,40,000 and start afresh. '
          'Every small contribution brings his family closer to relief.',
      imageUrl: 'https://picsum.photos/seed/donexia-loan1/800/500',
      createdAt: now.subtract(const Duration(days: 12)),
      daysLeft: 18,
      // Grandfathered: seed loan campaigns count as fee-paid.
      registrationFeePaid: true,
      registrationFeeAmount: 99,
      registrationTxnId: 'DNXRF-SEED-001',
      updates: [
        'Verified by Donexia admin — loan statement checked.',
        '₹50,000 raised in the first week. Thank you, donors!',
      ],
    ),
    Campaign(
      id: 'cmp_002',
      title: 'दिल की सर्जरी के लिए मदद की ज़रूरत',
      beneficiaryName: 'Suresh Chandra',
      city: 'Kanpur',
      state: 'Uttar Pradesh',
      district: 'Kanpur Nagar',
      category: CampaignCategory.medical,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 500000,
      raisedAmount: 360000,
      donorCount: 486,
      story:
          'Suresh ji needs urgent heart surgery. The hospital estimate is '
          '₹5,00,000 and the family has arranged ₹1,40,000 so far. '
          'Doctors say surgery cannot wait. Your help can save a life.',
      imageUrl: 'https://picsum.photos/seed/donexia-med1/800/500',
      createdAt: now.subtract(const Duration(days: 6)),
      daysLeft: 9,
      updates: ['Hospital estimate verified by admin.'],
    ),
    Campaign(
      id: 'cmp_003',
      title: 'बेटी की पढ़ाई के लिए मदद',
      beneficiaryName: 'Anjali Verma',
      city: 'Lucknow',
      state: 'Uttar Pradesh',
      district: 'Lucknow',
      category: CampaignCategory.education,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 180000,
      raisedAmount: 129600,
      donorCount: 167,
      story:
          'Anjali scored 92% in Class 12 and got admission to a good '
          'college, but the annual fees of ₹1,80,000 are beyond her '
          'family\'s reach. Help her continue her education.',
      imageUrl: 'https://picsum.photos/seed/donexia-edu1/800/500',
      createdAt: now.subtract(const Duration(days: 9)),
      daysLeft: 21,
      // Grandfathered: seed Education campaigns count as fee-paid.
      registrationFeePaid: true,
      registrationFeeAmount: 99,
      registrationTxnId: 'DNXRF-SEED-003',
    ),
    Campaign(
      id: 'cmp_004',
      title: 'बाढ़ से घर टूटा — दोबारा बसने में मदद करें',
      beneficiaryName: 'Mohd. Salim',
      city: 'Gorakhpur',
      state: 'Uttar Pradesh',
      district: 'Gorakhpur',
      category: CampaignCategory.emergency,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 150000,
      raisedAmount: 100500,
      donorCount: 203,
      story:
          'Floods damaged Salim\'s house and washed away his small shop. '
          'The family is living in a relief shelter. Funds will rebuild '
          'the house and restart his shop.',
      imageUrl: 'https://picsum.photos/seed/donexia-emg1/800/500',
      createdAt: now.subtract(const Duration(days: 4)),
      daysLeft: 12,
      // Grandfathered: seed Emergency campaigns count as fee-paid.
      registrationFeePaid: true,
      registrationFeeAmount: 99,
      registrationTxnId: 'DNXRF-SEED-004',
    ),
    Campaign(
      id: 'cmp_005',
      title: 'कैंसर के इलाज में मदद — Hope and Healing',
      beneficiaryName: 'Meera Devi',
      city: 'Varanasi',
      state: 'Uttar Pradesh',
      district: 'Varanasi',
      category: CampaignCategory.medical,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 800000,
      raisedAmount: 400000,
      donorCount: 512,
      story:
          'Meera Devi is undergoing cancer treatment. Each chemotherapy '
          'cycle costs a lot and the family has exhausted its savings. '
          'Your donation keeps her treatment going.',
      imageUrl: 'https://picsum.photos/seed/donexia-med2/800/500',
      createdAt: now.subtract(const Duration(days: 15)),
      daysLeft: 25,
    ),
    Campaign(
      id: 'cmp_006',
      title: 'होम लोन की EMI में राहत चाहिए',
      beneficiaryName: 'Vikram Singh',
      city: 'Agra',
      state: 'Uttar Pradesh',
      district: 'Agra',
      category: CampaignCategory.loan,
      status: CampaignStatus.active,
      verified: false,
      targetAmount: 320000,
      raisedAmount: 64000,
      donorCount: 78,
      story:
          'Vikram\'s small business slowed down after an accident and his '
          'home-loan EMIs have piled up. He is seeking temporary relief '
          'to avoid losing his family home.',
      imageUrl: 'https://picsum.photos/seed/donexia-loan2/800/500',
      createdAt: now.subtract(const Duration(days: 3)),
      daysLeft: 27,
      // Grandfathered: seed loan campaigns count as fee-paid.
      registrationFeePaid: true,
      registrationFeeAmount: 99,
      registrationTxnId: 'DNXRF-SEED-006',
    ),
    Campaign(
      id: 'cmp_007',
      title: 'बच्चों की स्कूल फीस के लिए मदद',
      beneficiaryName: 'Sunita Yadav',
      city: 'Prayagraj',
      state: 'Uttar Pradesh',
      district: 'Prayagraj',
      category: CampaignCategory.education,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 95000,
      raisedAmount: 71250,
      donorCount: 141,
      story:
          'Sunita is a single mother of two school-going children. Pending '
          'school fees of ₹95,000 threaten their admission. Help keep '
          'both children in school.',
      imageUrl: 'https://picsum.photos/seed/donexia-edu2/800/500',
      createdAt: now.subtract(const Duration(days: 7)),
      daysLeft: 14,
      // Grandfathered: seed Education campaigns count as fee-paid.
      registrationFeePaid: true,
      registrationFeeAmount: 99,
      registrationTxnId: 'DNXRF-SEED-007',
    ),
    Campaign(
      id: 'cmp_008',
      title: 'सड़क हादसे के बाद इलाज के लिए मदद',
      beneficiaryName: 'Amit Patel',
      city: 'Jhansi',
      state: 'Uttar Pradesh',
      district: 'Jhansi',
      category: CampaignCategory.emergency,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 250000,
      raisedAmount: 187500,
      donorCount: 296,
      story:
          'Amit met with a road accident and needs multiple surgeries. '
          'His family has spent everything on the first operation. '
          'Further treatment depends on your support.',
      imageUrl: 'https://picsum.photos/seed/donexia-emg2/800/500',
      createdAt: now.subtract(const Duration(days: 5)),
      daysLeft: 10,
      // Grandfathered: seed Emergency campaigns count as fee-paid.
      registrationFeePaid: true,
      registrationFeeAmount: 99,
      registrationTxnId: 'DNXRF-SEED-008',
    ),
    Campaign(
      id: 'cmp_009',
      title: 'बिज़नेस लोन चुकाने में मदद',
      beneficiaryName: 'Kavita Sharma',
      city: 'Kanpur',
      state: 'Uttar Pradesh',
      district: 'Kanpur Nagar',
      category: CampaignCategory.loan,
      status: CampaignStatus.pending,
      verified: false,
      targetAmount: 500000,
      raisedAmount: 0,
      donorCount: 0,
      story:
          'Kavita runs a small tailoring unit. A business loan taken to '
          'buy machines is now overdue. This campaign is pending admin '
          'verification and is not yet public.',
      imageUrl: 'https://picsum.photos/seed/donexia-loan3/800/500',
      createdAt: now.subtract(const Duration(days: 1)),
      daysLeft: 30,
      // Grandfathered: seed loan campaigns count as fee-paid.
      registrationFeePaid: true,
      registrationFeeAmount: 99,
      registrationTxnId: 'DNXRF-SEED-009',
    ),
    Campaign(
      id: 'cmp_010',
      title: 'गुर्दे के इलाज (Dialysis) के लिए मदद',
      beneficiaryName: 'Ramesh Gupta',
      city: 'Lucknow',
      state: 'Uttar Pradesh',
      district: 'Lucknow',
      category: CampaignCategory.medical,
      status: CampaignStatus.active,
      verified: true,
      targetAmount: 600000,
      raisedAmount: 180000,
      donorCount: 189,
      story:
          'Ramesh ji needs regular dialysis and a possible transplant. '
          'The family cannot afford the long treatment alone. Every '
          'donation extends his treatment by weeks.',
      imageUrl: 'https://picsum.photos/seed/donexia-med3/800/500',
      createdAt: now.subtract(const Duration(days: 11)),
      daysLeft: 19,
    ),
  ];
}

/// Demo totals shown on Home (derived from seed in the app; these are
/// fallback display figures for the first launch).
const double kDemoTotalRaised = 4850000;
const int kDemoBeneficiariesHelped = 12450;
const int kDemoTotalCampaigns = 1240;
