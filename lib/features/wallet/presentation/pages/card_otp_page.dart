import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:gold_mobile/features/wallet/presentation/bloc/wallet_event.dart';

/// Generic OTP page used both for "add card" and "transfer".
/// expectedCode default = 111111. On success, calls [onVerified].
class WalletOtpPage extends StatefulWidget {
  const WalletOtpPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onVerified,
    this.expectedCode = '111111',
  });

  final String title;
  final String subtitle;
  final String expectedCode;
  final FutureOr<void> Function(BuildContext context) onVerified;

  @override
  State<WalletOtpPage> createState() => _WalletOtpPageState();
}

class _WalletOtpPageState extends State<WalletOtpPage> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  int _seconds = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // simulate SMS arrival
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Tasdiqlash kodi yuborildi',
          backgroundColor: AppColors.gold,
          textColor: Colors.black,
        );
      }
    });
  }

  void _startTimer() {
    _seconds = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (_busy) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 500));
    // Demo: accept any 6-digit code as success.
    if (code.length != 6) {
      setState(() => _busy = false);
      _ctrl.clear();
      Fluttertoast.showToast(
        msg: '6 xonali kod kiriting',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }
    await widget.onVerified(context);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultPin = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            20.h + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(IconsaxPlusBold.sms, color: AppColors.gold, size: 40),
              ),
              SizedBox(height: 16.h),
              Text(
                'Tasdiqlash kodi',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textMediumOnDark
                      : AppColors.textMedium,
                ),
              ),
              SizedBox(height: 24.h),
              Pinput(
                length: 6,
                controller: _ctrl,
                defaultPinTheme: defaultPin,
                focusedPinTheme: defaultPin.copyWith(
                  decoration: defaultPin.decoration!.copyWith(
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                ),
                onCompleted: _verify,
              ),
              SizedBox(height: 24.h),
              if (_busy)
                const CircularProgressIndicator(color: AppColors.gold)
              else if (_seconds > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40.r),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded,
                          size: 18.sp, color: AppColors.gold),
                      SizedBox(width: 6.w),
                      Text(
                        'Qayta yuborish: ${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    _startTimer();
                    Fluttertoast.showToast(
                      msg: 'Tasdiqlash kodi qayta yuborildi',
                      backgroundColor: AppColors.gold,
                      textColor: Colors.black,
                    );
                  },
                  icon: const Icon(IconsaxPlusBold.refresh,
                      color: AppColors.gold),
                  label: Text(
                    'Kodni qayta yuborish',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
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

/// Concrete OTP for adding a card. Reads payload from extra map.
class AddCardOtpPage extends StatelessWidget {
  const AddCardOtpPage({super.key, required this.payload});
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final number = payload['number'] as String;
    final masked =
        '**** **** **** ${number.substring(number.length - 4)}';
    return WalletOtpPage(
      title: 'Karta qo\'shish',
      subtitle:
          'Karta $masked uchun kelgan SMS kodni kiriting',
      onVerified: (ctx) async {
        ctx.read<WalletBloc>().add(AddCardSubmitted(
              number: number,
              holder: payload['holder'] as String,
              expiry: payload['expiry'] as String,
            ));
        Fluttertoast.showToast(
          msg: 'Karta muvaffaqiyatli qo\'shildi',
          backgroundColor: AppColors.success,
          textColor: Colors.white,
        );
        // Pop back to wallet
        ctx.go('/home');
        // open wallet tab via extra param (we just go home; user is already on wallet tab)
      },
    );
  }
}
