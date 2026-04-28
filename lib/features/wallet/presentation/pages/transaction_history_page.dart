import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_state.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key, this.initialCardId});
  final String? initialCardId;

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  TxType? _typeFilter;
  String? _cardIdFilter;
  DateTimeRange? _dateRange;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  bool get _hasExtraFilters => _cardIdFilter != null || _dateRange != null;

  @override
  void initState() {
    super.initState();
    _cardIdFilter = widget.initialCardId;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Tarix'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: () => _openFilters(context),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(IconsaxPlusLinear.filter),
                if (_hasExtraFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          final q = _query.trim().toLowerCase();
          final txs = state.transactions.where((t) {
            if (_typeFilter != null && t.type != _typeFilter) return false;
            if (_cardIdFilter != null && t.fromCardId != _cardIdFilter) {
              return false;
            }
            if (_dateRange != null) {
              final d = DateTime(t.date.year, t.date.month, t.date.day);
              final s = DateTime(_dateRange!.start.year,
                  _dateRange!.start.month, _dateRange!.start.day);
              final e = DateTime(_dateRange!.end.year, _dateRange!.end.month,
                  _dateRange!.end.day);
              if (d.isBefore(s) || d.isAfter(e)) return false;
            }
            if (q.isNotEmpty) {
              final amountStr = t.amount.toStringAsFixed(0);
              final amountFmt = MoneyFormat.sum(t.amount);
              final hay = [
                t.merchant,
                t.productName,
                t.toCardHolder,
                t.toCardNumber,
                t.note,
                t.type.label,
                amountStr,
                amountFmt,
              ].whereType<String>().join(' ').toLowerCase();
              // normalize: strip spaces from query for numeric matches
              final qDigits = q.replaceAll(RegExp(r'\s+'), '');
              if (!hay.contains(q) &&
                  !amountStr.contains(qDigits) &&
                  !amountFmt
                      .toLowerCase()
                      .replaceAll(RegExp(r'\s+'), '')
                      .contains(qDigits)) {
                return false;
              }
            }
            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                child: _HistorySearchField(
                  controller: _searchCtrl,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
              ),
              _typeChips(isDark),
              if (_hasExtraFilters) _activeFilterBar(isDark, state.cards),
              if (txs.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconsaxPlusLinear.receipt_search,
                          size: 56,
                          color: isDark
                              ? AppColors.textMediumOnDark
                              : AppColors.textMedium,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Hozircha amaliyotlar yo\'q',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMediumOnDark
                                : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(child: _groupedList(txs, state.cards, isDark)),
            ],
          );
        },
      ),
    );
  }

  // --------------------------- Type chips ---------------------------
  Widget _typeChips(bool isDark) {
    final items = <(TxType?, String, IconData)>[
      (null, 'Barchasi', IconsaxPlusBold.category),
      (TxType.transferOut, 'O\'tkazma', IconsaxPlusBold.send_2),
      (TxType.transferIn, 'Kirim', IconsaxPlusBold.receive_square_2),
      (TxType.payment, 'To\'lov', IconsaxPlusBold.receipt_2_1),
      (TxType.purchase, 'Xarid', IconsaxPlusBold.shopping_bag),
    ];
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final (type, label, icon) = items[i];
          final selected = _typeFilter == type;
          return _Chip(
            selected: selected,
            label: label,
            icon: icon,
            isDark: isDark,
            onTap: () => setState(() => _typeFilter = type),
          );
        },
      ),
    );
  }

  // --------------------------- Active filters bar ---------------------------
  Widget _activeFilterBar(bool isDark, List<BankCard> cards) {
    final df = DateFormat('dd.MM');
    final pieces = <_ActiveFilter>[];
    if (_cardIdFilter != null) {
      final c = cards.firstWhere(
        (e) => e.id == _cardIdFilter,
        orElse: () => cards.isNotEmpty
            ? cards.first
            : const BankCard(
                id: '',
                holder: '',
                number: '0000000000000000',
                expiry: '',
                type: CardType.uzcard,
                balance: 0,
                colorSeed: 0,
              ),
      );
      pieces.add(_ActiveFilter(
        icon: IconsaxPlusBold.card,
        label: '${c.type.label} ••${c.number.substring(c.number.length - 4)}',
        onClear: () => setState(() => _cardIdFilter = null),
      ));
    }
    if (_dateRange != null) {
      pieces.add(_ActiveFilter(
        icon: IconsaxPlusBold.calendar_1,
        label:
            '${df.format(_dateRange!.start)} – ${df.format(_dateRange!.end)}',
        onClear: () => setState(() => _dateRange = null),
      ));
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 4.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 6.h,
        children: pieces
            .map((f) => _ActiveFilterChip(filter: f, isDark: isDark))
            .toList(),
      ),
    );
  }

  // --------------------------- Grouped list ---------------------------
  Widget _groupedList(
      List<WalletTransaction> txs, List<BankCard> cards, bool isDark) {
    final groups = <DateTime, List<WalletTransaction>>{};
    for (final t in txs) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(d, () => []).add(t);
    }
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    final items = <Widget>[];
    for (final k in keys) {
      items.add(_DateHeader(date: k, isDark: isDark));
      final list = groups[k]!..sort((a, b) => b.date.compareTo(a.date));
      items.add(Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                .withOpacity(0.6),
          ),
        ),
        child: Column(
          children: [
            for (var i = 0; i < list.length; i++) ...[
              _TxRow(
                tx: list[i],
                cards: cards,
                isDark: isDark,
                onTap: () => context.push('/wallet/receipt', extra: list[i]),
              ),
              if (i < list.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 78.w),
                  child: Divider(
                    height: 1,
                    color: (isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight)
                        .withOpacity(0.4),
                  ),
                ),
            ],
          ],
        ),
      ));
      items.add(SizedBox(height: 12.h));
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 110.h),
      children: items,
    );
  }

  // --------------------------- Filter sheet ---------------------------
  Future<void> _openFilters(BuildContext context) async {
    final state = context.read<WalletBloc>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? tempCardId = _cardIdFilter;
    DateTimeRange? tempRange = _dateRange;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final df = DateFormat('dd.MM.yyyy');
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w,
                  20.h + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.dividerLight,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Filtr',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('Karta',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMedium,
                      )),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _SheetChoice(
                        selected: tempCardId == null,
                        label: 'Barchasi',
                        onTap: () => setLocal(() => tempCardId = null),
                      ),
                      ...state.cards.map((c) {
                        final last4 =
                            c.number.substring(c.number.length - 4);
                        return _SheetChoice(
                          selected: tempCardId == c.id,
                          label: '${c.type.label} ••$last4',
                          onTap: () => setLocal(() => tempCardId = c.id),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text('Sana',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMedium,
                      )),
                  SizedBox(height: 8.h),
                  InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: ctx,
                        firstDate: DateTime(now.year - 3),
                        lastDate: now,
                        initialDateRange: tempRange,
                      );
                      if (picked != null) {
                        setLocal(() => tempRange = picked);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          const Icon(IconsaxPlusBold.calendar_1,
                              color: AppColors.gold),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              tempRange == null
                                  ? 'Sana oralig\'ini tanlang'
                                  : '${df.format(tempRange!.start)}  –  ${df.format(tempRange!.end)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (tempRange != null)
                            IconButton(
                              icon: const Icon(IconsaxPlusLinear.close_circle),
                              onPressed: () =>
                                  setLocal(() => tempRange = null),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setLocal(() {
                              tempCardId = null;
                              tempRange = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(0, 50.h),
                            foregroundColor: isDark
                                ? AppColors.textDarkOnDark
                                : AppColors.textDark,
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: const Text('Tozalash'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cardIdFilter = tempCardId;
                              _dateRange = tempRange;
                            });
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(0, 50.h),
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Qo\'llash',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// Pieces
// =============================================================================

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.gold
        : (isDark ? AppColors.surfaceDark : Colors.white);
    final fg = selected
        ? Colors.black
        : (isDark ? AppColors.textDarkOnDark : AppColors.textDark);
    final border = selected
        ? AppColors.gold
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 16),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFilter {
  final IconData icon;
  final String label;
  final VoidCallback onClear;
  _ActiveFilter(
      {required this.icon, required this.label, required this.onClear});
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.filter, required this.isDark});
  final _ActiveFilter filter;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 4.h, 4.w, 4.h),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(filter.icon, color: AppColors.gold, size: 14),
          SizedBox(width: 6.w),
          Text(
            filter.label,
            style: TextStyle(
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
          InkWell(
            onTap: filter.onClear,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: const Icon(IconsaxPlusBold.close_circle,
                  color: AppColors.gold, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetChoice extends StatelessWidget {
  const _SheetChoice({
    required this.selected,
    required this.label,
    required this.onTap,
  });
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? AppColors.gold.withOpacity(0.18)
          : (isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F5)),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : (isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected
                  ? AppColors.gold
                  : (isDark
                      ? AppColors.textDarkOnDark
                      : AppColors.textDark),
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date, required this.isDark});
  final DateTime date;
  final bool isDark;

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Bugun';
    if (date == yesterday) return 'Kecha';
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 12.h, 4.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            _label(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({
    required this.tx,
    required this.cards,
    required this.isDark,
    this.onTap,
  });
  final WalletTransaction tx;
  final List<BankCard> cards;
  final bool isDark;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (tx.type) {
      case TxType.transferOut:
        return IconsaxPlusBold.send_2;
      case TxType.transferIn:
        return IconsaxPlusBold.receive_square_2;
      case TxType.topUp:
        return IconsaxPlusBold.wallet_add_1;
      case TxType.payment:
        return IconsaxPlusBold.receipt_2_1;
      case TxType.purchase:
        return IconsaxPlusBold.shopping_bag;
    }
  }

  Color get _color {
    final isIncome =
        tx.type == TxType.transferIn || tx.type == TxType.topUp;
    return isIncome ? AppColors.success : AppColors.error;
  }

  String _maskCard(String? number) {
    if (number == null || number.length < 4) return number ?? '';
    final last4 = number.substring(number.length - 4);
    return '•• $last4';
  }

  String? _sourceCardLast4() {
    if (tx.fromCardId == null) return null;
    final c = cards.firstWhere(
      (e) => e.id == tx.fromCardId,
      orElse: () => const BankCard(
        id: '',
        holder: '',
        number: '',
        expiry: '',
        type: CardType.uzcard,
        balance: 0,
        colorSeed: 0,
      ),
    );
    if (c.number.length < 4) return null;
    return c.number.substring(c.number.length - 4);
  }

  String get _title {
    switch (tx.type) {
      case TxType.transferOut:
        return tx.toCardHolder ?? _maskCard(tx.toCardNumber);
      case TxType.transferIn:
        return tx.toCardHolder ?? 'Kirim';
      case TxType.payment:
      case TxType.purchase:
        if (tx.merchant == null) return tx.type.label;
        final parts = tx.merchant!.split(' · ');
        return parts.length > 1 ? parts[1] : tx.merchant!;
      case TxType.topUp:
        return tx.merchant ?? 'Kartani to\'ldirish';
    }
  }

  String get _subtitle {
    final time = DateFormat('HH:mm').format(tx.date);
    String? extra;
    switch (tx.type) {
      case TxType.payment:
      case TxType.purchase:
        if (tx.merchant != null) {
          final parts = tx.merchant!.split(' · ');
          if (parts.length > 1) extra = parts[0];
        }
        extra ??= tx.type.label;
        break;
      case TxType.transferOut:
        extra = _maskCard(tx.toCardNumber);
        if (extra.isEmpty) extra = tx.type.label;
        break;
      case TxType.transferIn:
        extra = tx.toCardNumber != null
            ? _maskCard(tx.toCardNumber)
            : tx.type.label;
        break;
      case TxType.topUp:
        final last4 = _sourceCardLast4();
        extra = last4 != null ? 'Karta •• $last4' : tx.type.label;
        break;
    }
    return '$time  •  $extra';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome =
        tx.type == TxType.transferIn || tx.type == TxType.topUp;
    final sign = isIncome ? '+' : '−';
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            _Avatar(tx: tx, color: _color, icon: _icon),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$sign ${MoneyFormat.amount(tx.amount)}',
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'so\'m',
                  style: TextStyle(
                    color: (isDark
                            ? AppColors.textMediumOnDark
                            : AppColors.textMedium)
                        .withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.tx, required this.color, required this.icon});
  final WalletTransaction tx;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLogo = tx.merchantLogo != null;
    if (hasLogo) {
      return Container(
        width: 50.w,
        height: 50.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(7.w),
          child: Image.asset(
            tx.merchantLogo!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(icon, color: color, size: 22),
          ),
        ),
      );
    }
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.18),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({
    required this.controller,
    required this.isDark,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Mahsulot, do''kon yoki karta bo''yicha qidirish...',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.textMediumOnDark
                : AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            IconsaxPlusLinear.search_normal_1,
            color: AppColors.gold,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    IconsaxPlusBold.close_circle,
                    color: AppColors.textMedium,
                    size: 20,
                  ),
                  onPressed: onClear,
                ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }
}
