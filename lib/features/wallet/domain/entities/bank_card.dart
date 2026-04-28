import 'package:equatable/equatable.dart';

enum CardType { uzcard, humo, visa }

extension CardTypeX on CardType {
  String get label {
    switch (this) {
      case CardType.uzcard:
        return 'UZCARD';
      case CardType.humo:
        return 'HUMO';
      case CardType.visa:
        return 'VISA';
    }
  }

  /// 8600 -> Uzcard, 9860 -> Humo, 4 -> Visa
  static CardType detect(String number) {
    final n = number.replaceAll(RegExp(r'\s+'), '');
    if (n.startsWith('8600') || n.startsWith('5614')) return CardType.uzcard;
    if (n.startsWith('9860')) return CardType.humo;
    if (n.startsWith('4')) return CardType.visa;
    return CardType.uzcard;
  }
}

class BankCard extends Equatable {
  final String id;
  final String holder;
  final String number; // raw 16 digits
  final String expiry; // MM/YY
  final CardType type;
  final double balance;
  final int colorSeed; // 0..n for gradient palette
  final bool isPrimary;

  const BankCard({
    required this.id,
    required this.holder,
    required this.number,
    required this.expiry,
    required this.type,
    required this.balance,
    required this.colorSeed,
    this.isPrimary = false,
  });

  String get masked {
    final n = number.padRight(16, '0');
    return '${n.substring(0, 4)} •••• •••• ${n.substring(12, 16)}';
  }

  String get formatted {
    final n = number.padRight(16, '0');
    return '${n.substring(0, 4)} ${n.substring(4, 8)} ${n.substring(8, 12)} ${n.substring(12, 16)}';
  }

  BankCard copyWith({
    double? balance,
    String? holder,
    String? expiry,
    bool? isPrimary,
  }) {
    return BankCard(
      id: id,
      holder: holder ?? this.holder,
      number: number,
      expiry: expiry ?? this.expiry,
      type: type,
      balance: balance ?? this.balance,
      colorSeed: colorSeed,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'holder': holder,
        'number': number,
        'expiry': expiry,
        'type': type.name,
        'balance': balance,
        'colorSeed': colorSeed,
        'isPrimary': isPrimary,
      };

  factory BankCard.fromJson(Map<String, dynamic> json) => BankCard(
        id: json['id'] as String,
        holder: json['holder'] as String,
        number: json['number'] as String,
        expiry: json['expiry'] as String,
        type: CardType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CardType.uzcard,
        ),
        balance: (json['balance'] as num).toDouble(),
        colorSeed: (json['colorSeed'] as num?)?.toInt() ?? 0,
        isPrimary: (json['isPrimary'] as bool?) ?? false,
      );

  @override
  List<Object?> get props =>
      [id, number, expiry, balance, type, holder, isPrimary];
}
