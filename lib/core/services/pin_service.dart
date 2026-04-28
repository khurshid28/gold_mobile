import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores app PIN + biometric flags in SharedPreferences and exposes
/// helpers for setting / verifying / authenticating.
class PinService {
  PinService._();
  static final PinService instance = PinService._();

  static const _kPinHash = 'pin.hash';
  static const _kPinSalt = 'pin.salt';
  static const _kPinEnabled = 'pin.enabled';
  static const _kBiometricEnabled = 'pin.biometric_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  // ---------- Flags ----------
  Future<bool> isPinEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kPinEnabled) ?? false;
  }

  Future<void> setPinEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPinEnabled, v);
    if (!v) {
      await p.remove(_kPinHash);
      await p.remove(_kPinSalt);
      await p.setBool(_kBiometricEnabled, false);
    }
  }

  Future<bool> isBiometricEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kBiometricEnabled, v);
  }

  Future<bool> hasPin() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(_kPinHash) ?? '').isNotEmpty;
  }

  // ---------- Hashing ----------
  String _hash(String pin, String salt) {
    final bytes = utf8.encode('$salt|$pin');
    return sha256.convert(bytes).toString();
  }

  String _newSalt() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rnd = Uint8List.fromList(List.generate(16, (i) => (now >> i) & 0xFF));
    return base64Url.encode(rnd);
  }

  Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    final salt = _newSalt();
    await p.setString(_kPinSalt, salt);
    await p.setString(_kPinHash, _hash(pin, salt));
    await p.setBool(_kPinEnabled, true);
  }

  Future<bool> verifyPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    final hash = p.getString(_kPinHash);
    final salt = p.getString(_kPinSalt);
    if (hash == null || salt == null) return false;
    return _hash(pin, salt) == hash;
  }

  // ---------- Biometrics ----------
  Future<bool> canCheckBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final can = await _auth.canCheckBiometrics;
      return can;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> authenticate({String reason = 'Ilovaga kirish'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
