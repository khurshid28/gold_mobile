import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';

class WalletRepository {
  WalletRepository(this._prefs);

  static const _kCards = 'wallet_cards_v1';
  static const _kTx = 'wallet_tx_v1';
  static const _kSeeded = 'wallet_seeded_v2';

  final SharedPreferences _prefs;
  final _uuid = const Uuid();
  final _rng = Random();

  // ----- Cards -----
  List<BankCard> getCards() {
    final raw = _prefs.getString(_kCards);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => BankCard.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<void> _saveCards(List<BankCard> cards) async {
    await _prefs.setString(
      _kCards,
      jsonEncode(cards.map((e) => e.toJson()).toList()),
    );
  }

  Future<BankCard> addCard({
    required String number,
    required String holder,
    required String expiry,
  }) async {
    final cards = getCards();
    final card = BankCard(
      id: _uuid.v4(),
      holder: holder.toUpperCase(),
      number: number.replaceAll(RegExp(r'\s+'), ''),
      expiry: expiry,
      type: CardTypeX.detect(number),
      // Demo: berilgan random balans
      balance: 50000 + _rng.nextInt(9_950_000).toDouble(),
      colorSeed: cards.length,
    );
    cards.add(card);
    await _saveCards(cards);
    return card;
  }

  Future<void> removeCard(String id) async {
    final cards = getCards()..removeWhere((c) => c.id == id);
    await _saveCards(cards);
  }

  Future<void> updateCard(BankCard card) async {
    final cards = getCards();
    final idx = cards.indexWhere((c) => c.id == card.id);
    if (idx == -1) return;
    cards[idx] = card;
    await _saveCards(cards);
  }

  // ----- Transactions -----
  List<WalletTransaction> getTransactions() {
    final raw = _prefs.getString(_kTx);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> _saveTransactions(List<WalletTransaction> txs) async {
    await _prefs.setString(
      _kTx,
      jsonEncode(txs.map((e) => e.toJson()).toList()),
    );
  }

  Future<WalletTransaction> addTransaction(WalletTransaction tx) async {
    final txs = getTransactions()..add(tx);
    await _saveTransactions(txs);
    return tx;
  }

  // ----- High-level operations -----

  /// Demo: faqat 6 raqamli kod 111111 to'g'ri.
  String generateSmsCode() => '111111';

  /// Default commission for transfers (1%).
  static const double transferFeeRate = 0.01;

  Future<({BankCard card, WalletTransaction tx})> transfer({
    required BankCard from,
    required String toCardNumber,
    required String toHolder,
    required double amount,
    String? note,
    double? feeRate,
  }) async {
    final rate = feeRate ?? transferFeeRate;
    final fee = (amount * rate).roundToDouble();
    final total = amount + fee;
    final newBalance = from.balance - total;
    if (newBalance < 0) {
      throw Exception('Kartada mablag\' yetarli emas');
    }
    final updated = from.copyWith(balance: newBalance);
    await updateCard(updated);

    final tx = WalletTransaction(
      id: _uuid.v4(),
      type: TxType.transferOut,
      amount: amount,
      fee: fee,
      date: DateTime.now(),
      fromCardId: from.id,
      toCardNumber: toCardNumber,
      toCardHolder: toHolder,
      note: note,
    );
    await addTransaction(tx);
    return (card: updated, tx: tx);
  }

  Future<({BankCard card, WalletTransaction tx})> topUp({
    required BankCard card,
    required double amount,
  }) async {
    final updated = card.copyWith(balance: card.balance + amount);
    await updateCard(updated);
    final tx = WalletTransaction(
      id: _uuid.v4(),
      type: TxType.topUp,
      amount: amount,
      date: DateTime.now(),
      fromCardId: card.id,
    );
    await addTransaction(tx);
    return (card: updated, tx: tx);
  }

  Future<({BankCard card, WalletTransaction tx})> payment({
    required BankCard card,
    required double amount,
    required String merchant,
    String? note,
  }) async {
    if (card.balance - amount < 0) {
      throw Exception('Kartada mablag\' yetarli emas');
    }
    final updated = card.copyWith(balance: card.balance - amount);
    await updateCard(updated);
    final tx = WalletTransaction(
      id: _uuid.v4(),
      type: TxType.payment,
      amount: amount,
      date: DateTime.now(),
      fromCardId: card.id,
      merchant: merchant,
      note: note,
    );
    await addTransaction(tx);
    return (card: updated, tx: tx);
  }

  /// Birinchi ishga tushganda demo kartalar
  Future<void> seedIfEmpty() async {
    if (_prefs.getBool(_kSeeded) == true) return;
    // Migration v1 -> v2: remove demo top-up seed transactions.
    if (getCards().isNotEmpty) {
      final cleaned = getTransactions()
          .where((t) => !(t.type == TxType.topUp &&
              (t.merchant == null || t.merchant!.isEmpty) &&
              (t.note == null || t.note!.isEmpty)))
          .toList();
      await _saveTransactions(cleaned);
      await _prefs.setBool(_kSeeded, true);
      return;
    }
    final demoUz = BankCard(
      id: _uuid.v4(),
      holder: 'GOLD CLIENT',
      number: '8600312345678901',
      expiry: '12/28',
      type: CardType.uzcard,
      balance: 4_580_000,
      colorSeed: 0,
    );
    final demoHumo = BankCard(
      id: _uuid.v4(),
      holder: 'GOLD CLIENT',
      number: '9860440011223344',
      expiry: '08/27',
      type: CardType.humo,
      balance: 1_250_000,
      colorSeed: 1,
    );
    await _saveCards([demoUz, demoHumo]);

    final now = DateTime.now();
    await _saveTransactions([
      WalletTransaction(
        id: _uuid.v4(),
        type: TxType.purchase,
        amount: 320_000,
        date: now.subtract(const Duration(days: 2, hours: 4)),
        fromCardId: demoUz.id,
        merchant: 'Gold Imperia',
        note: 'Uzuk xaridi',
      ),
      WalletTransaction(
        id: _uuid.v4(),
        type: TxType.transferOut,
        amount: 150_000,
        date: now.subtract(const Duration(days: 3)),
        fromCardId: demoHumo.id,
        toCardNumber: '8600 5544 3322 1100',
        toCardHolder: 'AKMAL KARIMOV',
      ),
    ]);
    await _prefs.setBool(_kSeeded, true);
  }
}
