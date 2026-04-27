import 'package:equatable/equatable.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';

class WalletState extends Equatable {
  final bool loading;
  final List<BankCard> cards;
  final List<WalletTransaction> transactions;
  final String? error;

  const WalletState({
    this.loading = false,
    this.cards = const [],
    this.transactions = const [],
    this.error,
  });

  double get totalBalance =>
      cards.fold<double>(0, (sum, c) => sum + c.balance);

  WalletState copyWith({
    bool? loading,
    List<BankCard>? cards,
    List<WalletTransaction>? transactions,
    String? error,
    bool clearError = false,
  }) {
    return WalletState(
      loading: loading ?? this.loading,
      cards: cards ?? this.cards,
      transactions: transactions ?? this.transactions,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [loading, cards, transactions, error];
}
