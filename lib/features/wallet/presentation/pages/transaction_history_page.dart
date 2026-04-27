import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_state.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  TxType? _filter;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Tarix'),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          var txs = state.transactions;
          if (_filter != null) {
            txs = txs.where((t) => t.type == _filter).toList();
          }
          return Column(
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 38.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  children: [
                    _chip(null, 'Barchasi'),
                    _chip(TxType.transferOut, 'O\'tkazma'),
                    _chip(TxType.topUp, 'To\'ldirish'),
                    _chip(TxType.payment, 'To\'lov'),
                    _chip(TxType.purchase, 'Xarid'),
                  ],
                ),
              ),
              if (txs.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Hozircha amaliyotlar yo\'q',
                      style: TextStyle(color: AppColors.textMedium),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: txs.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.dividerLight.withOpacity(0.4),
                    ),
                    itemBuilder: (context, i) {
                      final tx = txs[i];
                      final isIncome = tx.type == TxType.transferIn ||
                          tx.type == TxType.topUp;
                      final color =
                          isIncome ? AppColors.success : AppColors.error;
                      return ListTile(
                        onTap: () =>
                            context.push('/wallet/receipt', extra: tx),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.12),
                          child: Icon(
                            isIncome
                                ? IconsaxPlusBold.arrow_down
                                : IconsaxPlusBold.arrow_up_2,
                            color: color,
                          ),
                        ),
                        title: Text(
                          tx.type.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          df.format(tx.date),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'} ${MoneyFormat.sum(tx.amount)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(TxType? type, String label) {
    final selected = _filter == type;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        selectedColor: AppColors.gold.withOpacity(0.18),
        labelStyle: TextStyle(
          color: selected ? AppColors.gold : null,
          fontWeight: FontWeight.w700,
        ),
        onSelected: (_) => setState(() => _filter = type),
      ),
    );
  }
}
