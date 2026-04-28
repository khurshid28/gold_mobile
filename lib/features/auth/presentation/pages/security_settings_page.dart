import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:local_auth/local_auth.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/services/pin_service.dart';
import 'package:gold_mobile/core/widgets/app_back_button.dart';
import 'package:gold_mobile/core/widgets/pin_setup_page.dart';

/// Security settings: enable PIN + biometric.
/// If [postLogin] is true, shows a "Davom etish" button that goes to /home.
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key, this.postLogin = false});
  final bool postLogin;

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _bioSupported = false;
  bool _isFace = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = PinService.instance;
    final pinEnabled = await svc.isPinEnabled();
    final bioEnabled = await svc.isBiometricEnabled();
    final canBio = await svc.canCheckBiometrics();
    final types = await svc.availableBiometrics();
    if (!mounted) return;
    setState(() {
      _pinEnabled = pinEnabled;
      _biometricEnabled = bioEnabled;
      _bioSupported = canBio;
      _isFace = types.contains(BiometricType.face);
      _loaded = true;
    });
  }

  Future<void> _onPinChanged(bool v) async {
    if (v) {
      // Open setup page; only enable on success.
      final created = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PinSetupPage()),
      );
      if (created != true) return;
      if (!mounted) return;
      setState(() => _pinEnabled = true);
      Fluttertoast.showToast(
        msg: 'PIN-kod yoqildi',
        backgroundColor: AppColors.gold,
        textColor: Colors.black,
      );
    } else {
      await PinService.instance.setPinEnabled(false);
      if (!mounted) return;
      setState(() {
        _pinEnabled = false;
        _biometricEnabled = false;
      });
    }
  }

  Future<void> _onBiometricChanged(bool v) async {
    if (!_pinEnabled) {
      Fluttertoast.showToast(
        msg: 'Avval PIN-kodni yoqing',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }
    if (v) {
      final ok = await PinService.instance
          .authenticate(reason: 'Biometrikani yoqish');
      if (!ok) return;
    }
    await PinService.instance.setBiometricEnabled(v);
    if (!mounted) return;
    setState(() => _biometricEnabled = v);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: widget.postLogin ? null : const AppBackButton(),
        automaticallyImplyLeading: !widget.postLogin,
        title: const Text('Xavfsizlik'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            if (widget.postLogin) ...[
              SizedBox(height: 8.h),
              Center(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(IconsaxPlusBold.shield_tick,
                      color: AppColors.gold, size: 36),
                ),
              ),
              SizedBox(height: 14.h),
              Center(
                child: Text(
                  'Hisobingizni himoyalang',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Center(
                child: Text(
                  'Ilova ochilganda va 30 soniya jimlikdan so\'ng PIN so\'raladi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.textMediumOnDark
                        : AppColors.textMedium,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
            ],
            _Tile(
              icon: IconsaxPlusBold.password_check,
              title: 'PIN-kod',
              subtitle:
                  'Ilovaga kirish uchun 6 xonali himoya kodi',
              value: _pinEnabled,
              onChanged: _onPinChanged,
              isDark: isDark,
            ),
            SizedBox(height: 12.h),
            _Tile(
              icon: _isFace
                  ? IconsaxPlusBold.scan
                  : IconsaxPlusBold.finger_scan,
              title: _isFace ? 'Face ID' : 'Barmoq izi',
              subtitle: _bioSupported
                  ? 'Ilovaga PIN o\'rniga biometrika orqali kirish'
                  : 'Ushbu qurilmada biometrika qo\'llab-quvvatlanmaydi',
              value: _biometricEnabled,
              enabled: _bioSupported && _pinEnabled,
              onChanged: _onBiometricChanged,
              isDark: isDark,
            ),
            if (widget.postLogin) ...[
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    _pinEnabled ? 'Davom etish' : 'O\'tkazib yuborish',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
    this.enabled = true,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.gold),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.textMediumOnDark
                          : AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}
