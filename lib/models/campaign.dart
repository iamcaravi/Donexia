/// Campaign model — public fields only.
/// NEVER store or expose loan/bank account numbers, Aadhaar, PAN or
/// private medical documents on a public campaign object.
enum CampaignCategory { loan, medical, education, emergency }

extension CampaignCategoryLabel on CampaignCategory {
  String get label {
    switch (this) {
      case CampaignCategory.loan:
        return 'Loan Relief';
      case CampaignCategory.medical:
        return 'Medical Help';
      case CampaignCategory.education:
        return 'Education';
      case CampaignCategory.emergency:
        return 'Emergency';
    }
  }

  String get labelHi {
    switch (this) {
      case CampaignCategory.loan:
        return 'लोन में मदद';
      case CampaignCategory.medical:
        return 'इलाज के लिए';
      case CampaignCategory.education:
        return 'पढ़ाई में मदद';
      case CampaignCategory.emergency:
        return 'आपात मदद';
    }
  }

  /// ₹99 one-time registration fee applies to every category
  /// EXCEPT Medical, which is free.
  bool get requiresRegistrationFee => this != CampaignCategory.medical;
}

enum CampaignStatus {
  draft,
  pending,
  approved,
  rejected,
  moreInfo,
  active,
  completed,
  suspended,
}

extension CampaignStatusLabel on CampaignStatus {
  String get label {
    switch (this) {
      case CampaignStatus.draft:
        return 'Draft';
      case CampaignStatus.pending:
        return 'Pending Verification';
      case CampaignStatus.approved:
        return 'Approved';
      case CampaignStatus.rejected:
        return 'Rejected';
      case CampaignStatus.moreInfo:
        return 'More Info Required';
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.completed:
        return 'Completed';
      case CampaignStatus.suspended:
        return 'Suspended';
    }
  }

  bool get isPublic =>
      this == CampaignStatus.approved || this == CampaignStatus.active;
}

class Campaign {
  final String id;
  final String title;
  final String beneficiaryName;
  final String city;
  final String state;
  final String district;
  final CampaignCategory category;
  final CampaignStatus status;
  final bool verified;
  final double targetAmount;
  final double raisedAmount;
  final int donorCount;
  final String story;
  final String imageUrl;
  final DateTime createdAt;
  final int daysLeft;
  final List<String> updates;
  final String? rejectionReason;
  // One-time registration fee (₹99) — Loan, Education and Emergency
  // campaigns. Medical campaigns are free (amount 0).
  final bool registrationFeePaid;
  final int registrationFeeAmount;
  final String? registrationTxnId;

  static const int registrationFee = 99;

  const Campaign({
    required this.id,
    required this.title,
    required this.beneficiaryName,
    required this.city,
    required this.state,
    required this.district,
    required this.category,
    required this.status,
    required this.verified,
    required this.targetAmount,
    required this.raisedAmount,
    required this.donorCount,
    required this.story,
    required this.imageUrl,
    required this.createdAt,
    required this.daysLeft,
    this.updates = const [],
    this.rejectionReason,
    this.registrationFeePaid = false,
    this.registrationFeeAmount = 0,
    this.registrationTxnId,
  });

  double get progress =>
      targetAmount <= 0 ? 0 : (raisedAmount / targetAmount).clamp(0, 1);
  double get remaining => (targetAmount - raisedAmount).clamp(0, targetAmount);
  int get progressPercent => (progress * 100).round();

  Campaign copyWith({
    CampaignStatus? status,
    double? raisedAmount,
    int? donorCount,
    String? rejectionReason,
    List<String>? updates,
    bool? registrationFeePaid,
    int? registrationFeeAmount,
    String? registrationTxnId,
  }) {
    return Campaign(
      id: id,
      title: title,
      beneficiaryName: beneficiaryName,
      city: city,
      state: state,
      district: district,
      category: category,
      status: status ?? this.status,
      verified: verified,
      targetAmount: targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      donorCount: donorCount ?? this.donorCount,
      story: story,
      imageUrl: imageUrl,
      createdAt: createdAt,
      daysLeft: daysLeft,
      updates: updates ?? this.updates,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      registrationFeePaid: registrationFeePaid ?? this.registrationFeePaid,
      registrationFeeAmount:
          registrationFeeAmount ?? this.registrationFeeAmount,
      registrationTxnId: registrationTxnId ?? this.registrationTxnId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'beneficiaryName': beneficiaryName,
    'city': city,
    'state': state,
    'district': district,
    'category': category.name,
    'status': status.name,
    'verified': verified,
    'targetAmount': targetAmount,
    'raisedAmount': raisedAmount,
    'donorCount': donorCount,
    'story': story,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
    'daysLeft': daysLeft,
    'updates': updates,
    'rejectionReason': rejectionReason,
    'registrationFeePaid': registrationFeePaid,
    'registrationFeeAmount': registrationFeeAmount,
    'registrationTxnId': registrationTxnId,
  };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json['id'] as String,
    title: json['title'] as String,
    beneficiaryName: json['beneficiaryName'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    district: json['district'] as String,
    category: CampaignCategory.values.byName(json['category'] as String),
    status: CampaignStatus.values.byName(json['status'] as String),
    verified: json['verified'] as bool? ?? false,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    raisedAmount: (json['raisedAmount'] as num).toDouble(),
    donorCount: json['donorCount'] as int? ?? 0,
    story: json['story'] as String,
    imageUrl: json['imageUrl'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    daysLeft: json['daysLeft'] as int? ?? 0,
    updates: List<String>.from(json['updates'] as List? ?? const []),
    rejectionReason: json['rejectionReason'] as String?,
    // Defaults keep old stored campaigns (saved before the fee) readable.
    registrationFeePaid: json['registrationFeePaid'] as bool? ?? false,
    registrationFeeAmount: json['registrationFeeAmount'] as int? ?? 0,
    registrationTxnId: json['registrationTxnId'] as String?,
  );
}

/// Private payment-destination details.
/// Kept OUT of Campaign — stored locally only, visible only to the
/// owner and to admin verification. Never rendered on public screens.
class PaymentDestination {
  final String beneficiaryName;
  final String? upiId;
  final String? upiQrImagePath;
  final String? bankName;
  final String? accountHolderName;
  // Account number is stored only in the local demo store; never shown
  // in full on any public screen. Admin view masks it.
  final String? maskedAccountNumber;

  const PaymentDestination({
    required this.beneficiaryName,
    this.upiId,
    this.upiQrImagePath,
    this.bankName,
    this.accountHolderName,
    this.maskedAccountNumber,
  });
}
