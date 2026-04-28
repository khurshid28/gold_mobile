import 'package:equatable/equatable.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {
  const LoadWallet();
}

class AddCardSubmitted extends WalletEvent {
  final String number;
  final String holder;
  final String expiry;
  const AddCardSubmitted({
    required this.number,
    required this.holder,
    required this.expiry,
  });
  @override
  List<Object?> get props => [number, holder, expiry];
}

class RemoveCard extends WalletEvent {
  final String id;
  const RemoveCard(this.id);
  @override
  List<Object?> get props => [id];
}

class SetPrimaryCard extends WalletEvent {
  final String id;
  const SetPrimaryCard(this.id);
  @override
  List<Object?> get props => [id];
}

class TransferRequested extends WalletEvent {
  final BankCard from;
  final String toCardNumber;
  final String toHolder;
  final double amount;
  final String? note;
  const TransferRequested({
    required this.from,
    required this.toCardNumber,
    required this.toHolder,
    required this.amount,
    this.note,
  });
  @override
  List<Object?> get props => [from, toCardNumber, toHolder, amount, note];
}

class TopUpRequested extends WalletEvent {
  final BankCard card;
  final double amount;
  const TopUpRequested({required this.card, required this.amount});
  @override
  List<Object?> get props => [card, amount];
}

class PaymentRequested extends WalletEvent {
  final BankCard card;
  final double amount;
  final String merchant;
  final String? note;
  const PaymentRequested({
    required this.card,
    required this.amount,
    required this.merchant,
    this.note,
  });
  @override
  List<Object?> get props => [card, amount, merchant, note];
}
