/// Bank / NBFC master list — admin-manageable (add / edit / deactivate).
class Bank {
  final String id;
  final String name;
  final String type; // 'Bank' | 'NBFC'
  final bool active;

  const Bank({
    required this.id,
    required this.name,
    required this.type,
    this.active = true,
  });

  Bank copyWith({String? name, String? type, bool? active}) => Bank(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    active: active ?? this.active,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'active': active,
  };

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String? ?? 'Bank',
    active: json['active'] as bool? ?? true,
  );
}

/// Default master list from the product spec (17 entries).
const List<Map<String, String>> kDefaultBanks = [
  {'name': 'SBI', 'type': 'Bank'},
  {'name': 'PNB', 'type': 'Bank'},
  {'name': 'Bank of Baroda', 'type': 'Bank'},
  {'name': 'Canara Bank', 'type': 'Bank'},
  {'name': 'Union Bank', 'type': 'Bank'},
  {'name': 'Bank of India', 'type': 'Bank'},
  {'name': 'Indian Bank', 'type': 'Bank'},
  {'name': 'HDFC Bank', 'type': 'Bank'},
  {'name': 'ICICI Bank', 'type': 'Bank'},
  {'name': 'Axis Bank', 'type': 'Bank'},
  {'name': 'Kotak Mahindra Bank', 'type': 'Bank'},
  {'name': 'Bajaj Finance', 'type': 'NBFC'},
  {'name': 'Tata Capital', 'type': 'NBFC'},
  {'name': 'Shriram Finance', 'type': 'NBFC'},
  {'name': 'Muthoot Finance', 'type': 'NBFC'},
  {'name': 'Manappuram Finance', 'type': 'NBFC'},
  {'name': 'Other', 'type': 'Other'},
];

List<Bank> defaultBanks() => [
  for (var i = 0; i < kDefaultBanks.length; i++)
    Bank(
      id: 'bank_${i + 1}',
      name: kDefaultBanks[i]['name']!,
      type: kDefaultBanks[i]['type']!,
    ),
];
