import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:local_auth/local_auth.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/services/pin_service.dart';
import 'package:gold_mobile/core/widgets/numeric_keypad.dart';
import 'package:gold_mobile/core/widgets/pin_setup_page.dart' show kPinLength;

/// Full-screen PIN lock screen.
/// On successful PIN or biometric, calls [onUnlocked] (defaults to popping
/// the route with `true`).
class PinLockPage extends StatefulWidget {
  const PinLockPage({
    super.key,
    this.onUnlocked,
    this.allowBiometric = true,
    this.title = 'Ilova bloklangan',
    this.subtitle = 'Davom etish uchun PIN-kodni kiriting',
  });

  final VoidCallback? onUnlocked;
  final bool allowBiometric;
  final String title;
  final String subtitle;

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  String _input = '';
  bool _busy = false;
  bool _error = false;
  bool _hasBiometric = false;
  bool _isFace = false;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    if (!widget.allowBiometric) return;
    final svc = PinService.instance;
    final enabled = await svc.isBiometricEnabled();
    final supported = await svc.canCheckBiometrics();
    if (!enabled || !supported) {
      if (mounted) setState(() => _hasBiometric = false);
      return;
    }
    final types = await svc.availableBiometrics();
    if (!mounted) return;
    setState(() {
      _hasBiometric = true;
      _isFace = types.contains(BiometricType.face);
    });
    // Auto-prompt biometric on open.
    Future.delayed(const Duration(milliseconds: 250), _useBiometric);
  }

  Future<void> _useBiometric() async {
    if (!_hasBiometric || _busy) return;
    setState(() => _busy = true);
    final ok = await PinService.instance.authenticate();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) _success();
  }

  void _success() {
    if (widget.onUnlocked != null) {
      widget.onUnlocked!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _onDigit(String d) async {
    if (_busy || _input.length >= kPinLength) return;
    setState(() {
      _input += d;
      _error = false;
    });
    if (_input.length == kPinLength) {
      setState(() => _busy = true);
      final ok = await PinService.instance.verifyPin(_input);
      if (!mounted) return;
      if (ok) {
        _success();
      } else {
        setState(() {
          _busy = false;
          _error = true;
          _input = '';
        });
        Fluttertoast.showToast(
          msg: 'PIN-kod xato',
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      }
    }
  }

  void _onBack() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF14110E),
                Color(0xFF1F1A12),
                Color(0xFF0E0C09),
              ],
              stops: [0, 0.55, 1],
            ),
          ),
          child: Stack(
            children: [
              // Soft gold radial glow
              Positioned(
                top: -120.h,
                left: -60.w,
                right: -60.w,
                child: Container(
                  height: 280.h,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withOpacity(0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    children: [
                      SizedBox(height: 28.h),
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.gold.withOpacity(0.30),
                              AppColors.gold.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.45),
                            width: 1,
                          ),
                        ),
                        child: const Icon(IconsaxPlusBold.lock_1,
                            color: AppColors.gold, size: 38),
                      ),
                      SizedBox(height: 22.h),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textMediumOnDark,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      PinDots(
                        length: kPinLength,
                        filled: _input.length,
                        color: Colors.white,
                        error: _error,
                      ),
                      const Spacer(),
                      NumericKeypad(
                        onDarkBackground: true,
                        color: Colors.white,
                        backspaceColor: Colors.white,
                        onDigit: _onDigit,
                        onBackspace: _onBack,
                        leftAction: _hasBiometric
                            ? _BiometricButton(
                                isFace: _isFace,
                                onTap: _useBiometric,
                              )
                            : null,
                      ),
                      SizedBox(height: 8.h),
                    ],
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

class _BiometricButton extends StatelessWidget {
  const _BiometricButton({required this.isFace, required this.onTap});
  final bool isFace;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withOpacity(0.10),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.45),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            isFace ? IconsaxPlusBold.scan : IconsaxPlusBold.finger_scan,
            color: AppColors.gold,
            size: 30,
          ),
        ),
      ),
    );
  }
}
