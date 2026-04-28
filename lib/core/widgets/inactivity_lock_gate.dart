import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:gold_mobile/core/services/pin_service.dart';
import 'package:gold_mobile/core/widgets/pin_lock_page.dart';

/// Wraps the entire app and overlays [PinLockPage] when:
/// - the app has been idle for [timeout] (default 30s); or
/// - the app returns from background after >5s.
///
/// Skipped while PIN is disabled in [PinService] or while the user is on
/// auth-related routes (set via [currentRoute]).
class InactivityLockGate extends StatefulWidget {
  const InactivityLockGate({
    super.key,
    required this.child,
    required this.currentRoute,
    this.timeout = const Duration(seconds: 30),
    this.skipRoutes = const ['/', '/phone-login', '/otp-verify', '/security'],
  });

  final Widget child;
  final ValueListenable<String> currentRoute;
  final Duration timeout;
  final List<String> skipRoutes;

  @override
  State<InactivityLockGate> createState() => _InactivityLockGateState();
}

class _InactivityLockGateState extends State<InactivityLockGate>
    with WidgetsBindingObserver {
  Timer? _idleTimer;
  bool _locked = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetIdle();
    widget.currentRoute.addListener(_onRouteChanged);
    _checkColdLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.currentRoute.removeListener(_onRouteChanged);
    _idleTimer?.cancel();
    super.dispose();
  }

  bool _coldLockChecked = false;

  /// Check on app start (and on first navigation to a non-skip route)
  /// whether PIN should be required.
  Future<void> _checkColdLock() async {
    if (_coldLockChecked) return;
    if (_isSkipRoute()) return; // wait until user leaves splash/auth
    _coldLockChecked = true;
    final pinOn = await PinService.instance.isPinEnabled();
    final hasPin = await PinService.instance.hasPin();
    if (!pinOn || !hasPin) return;
    if (mounted) setState(() => _locked = true);
  }

  void _onRouteChanged() {
    _checkColdLock();
  }

  bool _isSkipRoute() {
    final loc = widget.currentRoute.value;
    for (final p in widget.skipRoutes) {
      if (loc == p) return true;
      if (p != '/' && loc.startsWith('$p/')) return true;
    }
    return false;
  }

  void _resetIdle() {
    _idleTimer?.cancel();
    if (_locked) return;
    _idleTimer = Timer(widget.timeout, _maybeLock);
  }

  Future<void> _maybeLock() async {
    if (_locked) return;
    if (_isSkipRoute()) {
      _resetIdle();
      return;
    }
    final pinOn = await PinService.instance.isPinEnabled();
    final hasPin = await PinService.instance.hasPin();
    if (!pinOn || !hasPin) {
      _resetIdle();
      return;
    }
    if (mounted) setState(() => _locked = true);
  }

  void _unlock() {
    if (!mounted) return;
    setState(() => _locked = false);
    _resetIdle();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (since != null &&
          DateTime.now().difference(since) >=
              const Duration(seconds: 5)) {
        _maybeLock();
      } else {
        _resetIdle();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetIdle(),
      onPointerMove: (_) => _resetIdle(),
      onPointerUp: (_) => _resetIdle(),
      child: Stack(
        children: [
          widget.child,
          if (_locked)
            Positioned.fill(
              child: PinLockPage(onUnlocked: _unlock),
            ),
        ],
      ),
    );
  }
}
