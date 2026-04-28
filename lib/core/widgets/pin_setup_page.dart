import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/services/pin_service.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/widgets/numeric_keypad.dart';

const int kPinLength = 6;

/// Two-step PIN creation: enter, then confirm.
/// Calls [onCreated] with the final PIN once confirmed.
/// If [onCreated] is null, saves to [PinService] automatically and pops.
class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key, this.onCreated, this.title});

  final String? title;
  final Future<void> Function(String pin)? onCreated;

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String _first = '';
  String _input = '';
  bool _confirming = false;
  bool _error = false;

  void _onDigit(String d) {
    if (_input.length >= kPinLength) return;
    setState(() {
      _input += d;
      _error = false;
    });
    if (_input.length == kPinLength) {
      Future.delayed(const Duration(milliseconds: 120), _commit);
    }
  }

  void _onBack() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _error = false;
    });
  }

  Future<void> _commit() async {
    if (!_confirming) {
      setState(() {
        _first = _input;
        _input = '';
        _confirming = true;
      });
      return;
    }
    if (_input != _first) {
      setState(() {
        _error = true;
        _input = '';
      });
      Fluttertoast.showToast(
        msg: 'PIN-kodlar mos kelmadi',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }
    final pin = _input;
    if (widget.onCreated != null) {
      await widget.onCreated!(pin);
    } else {
      await PinService.instance.setPin(pin);
      Fluttertoast.showToast(
        msg: 'PIN-kod o\'rnatildi',
        backgroundColor: AppColors.gold,
        textColor: Colors.black,
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.title ?? 'PIN-kod yaratish'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) {
                  final active = (_confirming ? 1 : 0) >= i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: active ? 28.w : 12.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.gold
                          : AppColors.gold.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  );
                }),
              ),
              SizedBox(height: 22.h),
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(0.22),
                      AppColors.gold.withOpacity(0.04),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.35),
                  ),
                ),
                child: Icon(
                  _confirming
                      ? IconsaxPlusBold.shield_tick
                      : IconsaxPlusBold.lock_1,
                  color: AppColors.gold,
                  size: 34,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _confirming
                    ? 'PIN-kodni tasdiqlang'
                    : 'Yangi PIN-kod kiriting',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                _confirming
                    ? 'Xuddi shu 6 xonali kodni qayta kiriting'
                    : '6 xonali himoya kodini o\'ylab toping',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textMediumOnDark
                      : AppColors.textMedium,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 28.h),
              PinDots(
                length: kPinLength,
                filled: _input.length,
                error: _error,
              ),
              const Spacer(),
              NumericKeypad(
                onDigit: _onDigit,
                onBackspace: _onBack,
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
