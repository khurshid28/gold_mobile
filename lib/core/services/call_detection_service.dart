import 'dart:async';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';

class CallDetectionService {
  static final CallDetectionService _instance =
      CallDetectionService._internal();
  factory CallDetectionService() => _instance;
  CallDetectionService._internal();

  StreamSubscription<PhoneState>? _subscription;
  final _callStateController = StreamController<CallState>.broadcast();

  Stream<CallState> get callStateStream => _callStateController.stream;
  CallState _currentState = CallState.idle;

  CallState get currentState => _currentState;

  Future<bool> requestPermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  Future<bool> checkPermission() async {
    final status = await Permission.phone.status;
    return status.isGranted;
  }

  Future<void> initialize() async {
    // Check if permission is granted
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      print('Phone permission not granted');
      return;
    }

    // Start listening to phone state changes
    _subscription = PhoneState.stream.listen((PhoneState state) {
      print('Phone state changed: ${state.status}');

      CallState newState = CallState.idle;

      switch (state.status) {
        case PhoneStateStatus.CALL_INCOMING:
          newState = CallState.incoming;
          break;
        case PhoneStateStatus.CALL_STARTED:
          newState = CallState.active;
          break;
        case PhoneStateStatus.CALL_ENDED:
          newState = CallState.ended;
          // After call ends, reset to idle
          Future.delayed(const Duration(seconds: 1), () {
            _currentState = CallState.idle;
            _callStateController.add(CallState.idle);
          });
          break;
        case PhoneStateStatus.NOTHING:
          newState = CallState.idle;
          break;
      }

      if (_currentState != newState) {
        _currentState = newState;
        _callStateController.add(newState);
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _callStateController.close();
  }
}

enum CallState { idle, incoming, active, ended }
