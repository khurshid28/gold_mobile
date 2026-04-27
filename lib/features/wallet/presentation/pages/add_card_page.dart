import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/features/wallet/domain/entities/bank_card.dart';
import 'package:gold_mobile/features/wallet/presentation/widgets/bank_card_widget.dart';

/// Step 1 — collect card data, then push OTP page.
class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();

  CardType _detected = CardType.uzcard;

  @override
  void initState() {
    super.initState();
    _numberCtrl.addListener(() {
      setState(() => _detected = CardTypeX.detect(_numberCtrl.text));
    });
    _expiryCtrl.addListener(() => setState(() {}));
    _holderCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _holderCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final number = _numberCtrl.text.replaceAll(RegExp(r'\s+'), '');
    context.push('/wallet/add-card/otp', extra: {
      'number': number,
      'expiry': _expiryCtrl.text,
      'holder': _holderCtrl.text.trim().isEmpty
          ? 'GOLD CLIENT'
          : _holderCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final rawNumber = _numberCtrl.text.replaceAll(RegExp(r'\s+'), '');
    // Pad to 16 digits with placeholder so the formatted number is always
    // "XXXX XXXX XXXX XXXX" — empty slots show as •.
    final padded = rawNumber.padRight(16, '•');
    final previewNumber = padded.substring(0, 16);
    final previewCard = BankCard(
      id: 'preview',
      number: previewNumber,
      holder: _holderCtrl.text.trim().isEmpty
          ? 'CARD HOLDER'
          : _holderCtrl.text.trim().toUpperCase(),
      expiry: _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text,
      type: _detected,
      balance: 0,
      colorSeed: 0,
    );
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Karta qo\'shish'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BankCardWidget(
                card: previewCard,
                showBalance: false,
                hideBrand: rawNumber.length < 4,
              ),
              SizedBox(height: 22.h),
              TextFormField(
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Karta raqami',
                  hintText: '8600 1234 5678 9012',
                  prefixIcon: Icon(IconsaxPlusLinear.card),
                ),
                onChanged: (v) {
                  setState(() => _detected = CardTypeX.detect(v));
                },
                validator: (v) {
                  final raw = (v ?? '').replaceAll(RegExp(r'\s+'), '');
                  if (raw.length != 16) return '16 raqam kiriting';
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _expiryCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amal qilish muddati (MM/YY)',
                  hintText: '12/28',
                  prefixIcon: Icon(IconsaxPlusLinear.calendar),
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(t)) {
                    return 'MM/YY kiriting';
                  }
                  final mm = int.tryParse(t.substring(0, 2)) ?? 0;
                  if (mm < 1 || mm > 12) return 'Oy noto\'g\'ri';
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _holderCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Karta egasi (ixtiyoriy)',
                  hintText: 'NAME SURNAME',
                  prefixIcon: Icon(IconsaxPlusLinear.user),
                ),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Davom etish',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String text = digits;
    if (digits.length >= 3) {
      text = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length == 2 &&
        oldValue.text.length < newValue.text.length) {
      text = '$digits/';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
