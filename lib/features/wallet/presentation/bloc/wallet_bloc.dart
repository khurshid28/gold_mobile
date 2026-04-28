import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gold_mobile/features/wallet/data/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repo;

  WalletBloc(this.repo) : super(const WalletState(loading: true)) {
    on<LoadWallet>(_onLoad);
    on<AddCardSubmitted>(_onAdd);
    on<RemoveCard>(_onRemove);
    on<SetPrimaryCard>(_onSetPrimary);
    on<TransferRequested>(_onTransfer);
    on<TopUpRequested>(_onTopUp);
    on<PaymentRequested>(_onPayment);
    add(const LoadWallet());
  }

  Future<void> _onLoad(LoadWallet event, Emitter<WalletState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    await repo.seedIfEmpty();
    emit(state.copyWith(
      loading: false,
      cards: repo.getCards(),
      transactions: repo.getTransactions(),
    ));
  }

  Future<void> _onAdd(
      AddCardSubmitted event, Emitter<WalletState> emit) async {
    try {
      await repo.addCard(
        number: event.number,
        holder: event.holder,
        expiry: event.expiry,
      );
      emit(state.copyWith(
        cards: repo.getCards(),
        transactions: repo.getTransactions(),
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRemove(RemoveCard event, Emitter<WalletState> emit) async {
    await repo.removeCard(event.id);
    emit(state.copyWith(cards: repo.getCards()));
  }

  Future<void> _onSetPrimary(
      SetPrimaryCard event, Emitter<WalletState> emit) async {
    await repo.setPrimary(event.id);
    emit(state.copyWith(cards: repo.getCards()));
  }

  Future<void> _onTransfer(
      TransferRequested event, Emitter<WalletState> emit) async {
    try {
      await repo.transfer(
        from: event.from,
        toCardNumber: event.toCardNumber,
        toHolder: event.toHolder,
        amount: event.amount,
        note: event.note,
      );
      emit(state.copyWith(
        cards: repo.getCards(),
        transactions: repo.getTransactions(),
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onTopUp(
      TopUpRequested event, Emitter<WalletState> emit) async {
    try {
      await repo.topUp(card: event.card, amount: event.amount);
      emit(state.copyWith(
        cards: repo.getCards(),
        transactions: repo.getTransactions(),
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onPayment(
      PaymentRequested event, Emitter<WalletState> emit) async {
    try {
      await repo.payment(
        card: event.card,
        amount: event.amount,
        merchant: event.merchant,
        note: event.note,
      );
      emit(state.copyWith(
        cards: repo.getCards(),
        transactions: repo.getTransactions(),
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
