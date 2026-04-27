import 'package:equatable/equatable.dart';

enum TxType { transferOut, transferIn, topUp, payment, purchase }

extension TxTypeX on TxType {
  String get label {
    switch (this) {
      case TxType.transferOut:
        return 'O\'tkazma';
      case TxType.transferIn:
        return 'Kirim';
      case TxType.topUp:
        return 'To\'ldirish';
      case TxType.payment:
        return 'To\'lov';
      case TxType.purchase:
        return 'Xarid';
    }
  }
}

class WalletTransaction extends Equatable {
  final String id;
  final TxType type;
  final double amount;
  final double fee;
  final String? fromCardId;
  final String? toCardNumber; // masked or raw
  final String? toCardHolder;
  final String? note;
  final DateTime date;
  final String? merchant; // for payments
  final bool success;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.fee = 0,
    this.fromCardId,
    this.toCardNumber,
    this.toCardHolder,
    this.note,
    this.merchant,
    this.success = true,
  });

  /// Total debited from the source card (amount + fee).
  double get totalCharged => amount + fee;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'fee': fee,
        'fromCardId': fromCardId,
        'toCardNumber': toCardNumber,
        'toCardHolder': toCardHolder,
        'note': note,
        'date': date.toIso8601String(),
        'merchant': merchant,
        'success': success,
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        type: TxType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TxType.payment,
        ),
        amount: (json['amount'] as num).toDouble(),
        fee: (json['fee'] as num?)?.toDouble() ?? 0,
        date: DateTime.parse(json['date'] as String),
        fromCardId: json['fromCardId'] as String?,
        toCardNumber: json['toCardNumber'] as String?,
        toCardHolder: json['toCardHolder'] as String?,
        note: json['note'] as String?,
        merchant: json['merchant'] as String?,
        success: json['success'] as bool? ?? true,
      );

  @override
  List<Object?> get props =>
      [id, type, amount, fee, fromCardId, toCardNumber, date, success];
}
