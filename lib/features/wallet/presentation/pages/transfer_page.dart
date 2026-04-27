import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/utils/money_format.dart';
import 'package:gold_mobile/features/wallet/data/wallet_repository.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:gold_mobile/features/wallet/presentation/pages/card_otp_page.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/card_picker.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key, required this.from});
  final BankCard from;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _toCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late BankCard _from = widget.from;
  String? _resolvedHolder;
  String? _maskedHolder;
  bool _holderLoading = false;

  @override
  void initState() {
    super.initState();
    _toCtrl.addListener(_onRecipientChanged);
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _toCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onRecipientChanged() {
    final raw = _toCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (raw.length == 16) {
      setState(() => _holderLoading = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final holder = _generateHolderFor(raw);
        setState(() {
          _resolvedHolder = holder;
          _maskedHolder = _maskHolder(holder);
          _holderLoading = false;
        });
      });
    } else if (_resolvedHolder != null || _maskedHolder != null) {
      setState(() {
        _resolvedHolder = null;
        _maskedHolder = null;
      });
    }
  }

  /// Deterministically pick a plausible Uzbek-style holder name based on the
  /// card number digits. Simulation only.
  String _generateHolderFor(String digits16) {
    const firsts = [
      'AKMAL', 'JAVOHIR', 'SARDOR', 'BEKZOD', 'OTABEK', 'ASILBEK',
      'NIGORA', 'MADINA', 'DILNOZA', 'SHAHZOD', 'JAMSHID', 'AZIZ',
    ];
    const lasts = [
      'KARIMOV', 'TOSHEV', 'YULDASHEV', 'SAIDOV', 'RAHIMOV',
      'ABDULLAEV', 'KAMOLOV', 'ISMOILOV', 'NORMUROD', 'XOLMATOV',
    ];
    final sum = digits16.codeUnits.fold<int>(0, (a, b) => a + b);
    final f = firsts[sum % firsts.length];
    final l = lasts[(sum ~/ 7) % lasts.length];
    return '$f $l';
  }

  /// Mask the holder so only the first letter of each word + last letter
  /// remain visible. e.g. "AKMAL KARIMOV" -> "A***L K*****V".
  String _maskHolder(String name) {
    return name.split(' ').map((w) {
      if (w.length <= 2) return w;
      final first = w[0];
      final last = w[w.length - 1];
      return '$first${'*' * (w.length - 2)}$last';
    }).join(' ');
  }

  double get _amount {
    final raw = _amountCtrl.text.replaceAll(RegExp(r'\s+'), '');
    return double.tryParse(raw) ?? 0;
  }

  double get _fee =>
      (_amount * WalletRepository.transferFeeRate).roundToDouble();
  double get _total => _amount + _fee;

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    if (_resolvedHolder == null) {
      Fluttertoast.showToast(msg: 'Karta egasini topib bo\'lmadi');
      return;
    }
    if (_total > _from.balance) {
      Fluttertoast.showToast(
        msg: 'Kartada mablag\' yetarli emas (komissiya bilan)',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }
    final toNumber = _toCtrl.text.replaceAll(RegExp(r'\s+'), '');
    final formatted =
        '${toNumber.substring(0, 4)} ${toNumber.substring(4, 8)} ${toNumber.substring(8, 12)} ${toNumber.substring(12, 16)}';

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WalletOtpPage(
        title: 'O\'tkazma',
        subtitle:
            '${MoneyFormat.sum(_amount)} miqdori uchun tasdiqlash kodi karta egasiga yuborildi',
        onVerified: (ctx) async {
          final repo = ctx.read<WalletBloc>().repo;
          try {
            final result = await repo.transfer(
              from: _from,
              toCardNumber: formatted,
              toHolder: _resolvedHolder!,
              amount: _amount,
              note: _noteCtrl.text.trim().isEmpty
                  ? null
                  : _noteCtrl.text.trim(),
            );
            ctx.read<WalletBloc>().add(const LoadWallet());
            Navigator.of(ctx).pop(); // pop OTP
            Navigator.of(ctx).pop(); // pop transfer
            ctx.push('/wallet/receipt', extra: result.tx);
          } catch (e) {
            Fluttertoast.showToast(
              msg: e.toString().replaceAll('Exception: ', ''),
              backgroundColor: AppColors.error,
              textColor: Colors.white,
            );
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('O\'tkazma'),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          final updated = state.cards.firstWhere(
            (c) => c.id == _from.id,
            orElse: () => _from,
          );
          _from = updated;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel(text: 'Qaysi kartadan'),
                  SizedBox(height: 8.h),
                  CardPickerTile(
                    selected: _from,
                    onChanged: (c) => setState(() => _from = c),
                  ),
                  SizedBox(height: 22.h),
                  const _SectionLabel(text: 'Qabul qiluvchi'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _toCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CardNumberFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Qabul qiluvchi karta raqami',
                      hintText: '8600 1234 5678 9012',
                      prefixIcon: const Icon(IconsaxPlusLinear.card),
                      suffixIcon: _holderLoading
                          ? Padding(
                              padding: EdgeInsets.all(12.w),
                              child: SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.gold,
                                ),
                              ),
                            )
                          : (_resolvedHolder != null
                              ? const Icon(IconsaxPlusBold.tick_circle,
                                  color: AppColors.success)
                              : null),
                    ),
                    validator: (v) {
                      final raw = (v ?? '').replaceAll(RegExp(r'\s+'), '');
                      if (raw.length != 16) return '16 raqam kiriting';
                      return null;
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    child: _maskedHolder == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: _HolderChip(name: _maskedHolder!),
                          ),
                  ),
                  SizedBox(height: 18.h),
                  const _SectionLabel(text: 'Summa'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Summa',
                      hintText: 'Masalan: 100 000',
                      prefixIcon: const Icon(IconsaxPlusLinear.dollar_circle),
                      suffixText: 'so\'m',
                      helperText: 'Mavjud: ${MoneyFormat.sum(_from.balance)}',
                    ),
                    validator: (v) {
                      final raw = (v ?? '').replaceAll(RegExp(r'\s+'), '');
                      final n = int.tryParse(raw) ?? 0;
                      if (n <= 0) return 'Summani kiriting';
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Izoh (ixtiyoriy)',
                      prefixIcon: Icon(IconsaxPlusLinear.edit),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  if (_amount > 0)
                    _FeeSummary(
                      amount: _amount,
                      fee: _fee,
                      total: _total,
                      isDark: isDark,
                    ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: _onContinue,
                      icon: const Icon(IconsaxPlusBold.arrow_swap_horizontal),
                      label: Text(
                        'O\'tkazish',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
      ),
    );
  }
}

class _HolderChip extends StatelessWidget {
  const _HolderChip({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          const Icon(IconsaxPlusBold.user, color: AppColors.gold, size: 18),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                letterSpacing: 1.2,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          const Icon(IconsaxPlusBold.shield_tick,
              color: AppColors.success, size: 18),
        ],
      ),
    );
  }
}

class _FeeSummary extends StatelessWidget {
  const _FeeSummary({
    required this.amount,
    required this.fee,
    required this.total,
    required this.isDark,
  });
  final double amount;
  final double fee;
  final double total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : AppColors.gold.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _row('O\'tkazma summasi', MoneyFormat.sum(amount)),
          SizedBox(height: 6.h),
          _row(
            'Komissiya (${(WalletRepository.transferFeeRate * 100).toStringAsFixed(0)}%)',
            MoneyFormat.sum(fee),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(
              color: AppColors.gold.withOpacity(0.3),
              height: 1,
            ),
          ),
          _row(
            'Jami yechiladi',
            MoneyFormat.sum(total),
            bold: true,
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textMediumOnDark
                : AppColors.textMedium,
            fontSize: bold ? 13.sp : 12.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight
                ? AppColors.gold
                : (isDark ? Colors.white : AppColors.textDark),
            fontSize: bold ? 14.sp : 12.sp,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\s+'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buf.write(digits[i]);
      if ((i + 1) % 4 == 0 && i != digits.length - 1) buf.write(' ');
    }
    return TextEditingValue(
      text: buf.toString(),
      selection: TextSelection.collapsed(offset: buf.length),
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
