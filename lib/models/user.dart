enum UserRole { donor, helpSeeker, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.donor:
        return 'Donor';
      case UserRole.helpSeeker:
        return 'Help Seeker';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String state;
  final String district;
  final String? photoPath;
  final Set<UserRole> roles;
  final bool termsAccepted;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.state,
    required this.district,
    this.photoPath,
    this.roles = const {UserRole.donor},
    this.termsAccepted = false,
    required this.createdAt,
  });

  bool get isAdmin => roles.contains(UserRole.admin);
  bool get isHelpSeeker => roles.contains(UserRole.helpSeeker);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'state': state,
    'district': district,
    'photoPath': photoPath,
    'roles': roles.map((r) => r.name).toList(),
    'termsAccepted': termsAccepted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
    state: json['state'] as String,
    district: json['district'] as String,
    photoPath: json['photoPath'] as String?,
    roles: (json['roles'] as List? ?? const ['donor'])
        .map((r) => UserRole.values.byName(r as String))
        .toSet(),
    termsAccepted: json['termsAccepted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class Donation {
  final String id;
  final String campaignId;
  final String campaignTitle;
  final String donorName;
  final double amount;
  final double platformFee; // 1% of amount
  final double beneficiaryAmount; // amount - fee
  final String method; // UPI / Card / Net Banking (demo)
  final String receiptId;
  final DateTime createdAt;

  const Donation({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.donorName,
    required this.amount,
    required this.platformFee,
    required this.beneficiaryAmount,
    required this.method,
    required this.receiptId,
    required this.createdAt,
  });

  /// 1% platform fee, rounded to 2 decimals.
  static double feeFor(double amount) =>
      double.parse((amount * 0.01).toStringAsFixed(2));

  static Donation create({
    required String campaignId,
    required String campaignTitle,
    required String donorName,
    required double amount,
    required String method,
  }) {
    final fee = feeFor(amount);
    final now = DateTime.now();
    return Donation(
      id: 'don_${now.millisecondsSinceEpoch}',
      campaignId: campaignId,
      campaignTitle: campaignTitle,
      donorName: donorName,
      amount: amount,
      platformFee: fee,
      beneficiaryAmount: double.parse(
        (amount - fee).toStringAsFixed(2),
      ),
      method: method,
      receiptId:
          'DNX${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 100000}',
      createdAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'campaignId': campaignId,
    'campaignTitle': campaignTitle,
    'donorName': donorName,
    'amount': amount,
    'platformFee': platformFee,
    'beneficiaryAmount': beneficiaryAmount,
    'method': method,
    'receiptId': receiptId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
    id: json['id'] as String,
    campaignId: json['campaignId'] as String,
    campaignTitle: json['campaignTitle'] as String,
    donorName: json['donorName'] as String,
    amount: (json['amount'] as num).toDouble(),
    platformFee: (json['platformFee'] as num).toDouble(),
    beneficiaryAmount: (json['beneficiaryAmount'] as num).toDouble(),
    method: json['method'] as String,
    receiptId: json['receiptId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
