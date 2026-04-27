import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:go_router/go_router.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/card_otp_page.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/bank_card_widget.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key, required this.card});
  final BankCard card;

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final _amountCtrl = TextEditingController();
  late BankCard _card = widget.card;

  static const _quick = [50_000, 100_000, 250_000, 500_000, 1_000_000];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _setAmount(int v) {
    _amountCtrl.text = MoneyFormat.amount(v);
    _amountCtrl.selection =
        TextSelection.collapsed(offset: _amountCtrl.text.length);
  }

  void _submit() {
    final raw = _amountCtrl.text.replaceAll(RegExp(r'\s+'), '');
    final amount = double.tryParse(raw) ?? 0;
    if (amount <= 0) {
      Fluttertoast.showToast(msg: 'Summani kiriting');
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WalletOtpPage(
        title: 'Kartani to\'ldirish',
        subtitle:
            '${MoneyFormat.sum(amount)} miqdor karta hisobiga qo\'shiladi',
        onVerified: (ctx) async {
          final repo = ctx.read<WalletBloc>().repo;
          final res = await repo.topUp(card: _card, amount: amount);
          ctx.read<WalletBloc>().add(const LoadWallet());
          Navigator.of(ctx).pop(); // pop OTP
          Navigator.of(ctx).pop(); // pop topup
          ctx.push('/wallet/receipt', extra: res.tx);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Kartani to\'ldirish'),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          _card = state.cards.firstWhere(
            (c) => c.id == _card.id,
            orElse: () => _card,
          );
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BankCardWidget(card: _card, height: 130.h, compact: true),
                SizedBox(height: 16.h),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Summa',
                    hintText: '100 000',
                    prefixIcon: Icon(IconsaxPlusLinear.money_recive),
                    suffixText: 'so\'m',
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _quick
                      .map((v) => ActionChip(
                            label: Text('+ ${MoneyFormat.amount(v)}'),
                            onPressed: () => _setAmount(v),
                            backgroundColor:
                                AppColors.gold.withOpacity(0.12),
                            labelStyle: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'To\'ldirish',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final n = int.tryParse(digits) ?? 0;
    final formatted = MoneyFormat.amount(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
