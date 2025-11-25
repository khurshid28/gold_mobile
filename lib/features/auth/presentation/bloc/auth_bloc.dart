import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gold_mobile/features/auth/data/models/user_model.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock: Always succeed
    emit(OtpSent(event.phoneNumber));
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock: Accept any 6-digit OTP
    if (event.otp.length == 6) {
      final user = UserModel(
        id: const Uuid().v4(),
        phoneNumber: event.phoneNumber,
        name: 'Foydalanuvchi',
      );
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_phone', user.phoneNumber);
      await prefs.setBool('is_logged_in', true);
      
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthError('Noto\'g\'ri tasdiqlash kodi'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (isLoggedIn) {
      final userId = prefs.getString('user_id') ?? '';
      final userPhone = prefs.getString('user_phone') ?? '';
      
      final user = UserModel(
        id: userId,
        phoneNumber: userPhone,
        name: 'Foydalanuvchi',
      );
      
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthInitial());
    }
  }
}
