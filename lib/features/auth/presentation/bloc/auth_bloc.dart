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
    on<UpdateUserProfile>(_onUpdateUserProfile);
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
      // Clear all previous data before logging in
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      final user = UserModel(
        id: const Uuid().v4(),
        phoneNumber: event.phoneNumber,
        name: 'Foydalanuvchi',
      );
      
      // Save to local storage
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
    
    // Clear all data (including cart, favorites, purchases)
    await prefs.clear();
    
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    print('DEBUG CheckAuthStatus: isLoggedIn=$isLoggedIn');
    
    if (isLoggedIn) {
      final userId = prefs.getString('user_id') ?? '';
      final userPhone = prefs.getString('user_phone') ?? '';
      final userName = prefs.getString('user_name');
      final isVerified = prefs.getBool('isVerified') ?? false;
      final creditLimit = prefs.getDouble('creditLimit');
      final usedLimit = prefs.getDouble('usedLimit') ?? 0.0;
      final limitExpiryString = prefs.getString('limitExpiryDate');
      
      print('DEBUG CheckAuthStatus: userName=$userName, isVerified=$isVerified');
      
      DateTime? limitExpiryDate;
      if (limitExpiryString != null) {
        limitExpiryDate = DateTime.tryParse(limitExpiryString);
      }
      
      final user = UserModel(
        id: userId,
        phoneNumber: userPhone,
        name: userName ?? 'Foydalanuvchi',
        isVerified: isVerified,
        creditLimit: creditLimit,
        usedLimit: usedLimit,
        limitExpiryDate: limitExpiryDate,
      );
      
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      
      // Create updated user with explicit values
      final updatedUser = UserModel(
        id: currentUser.id,
        phoneNumber: currentUser.phoneNumber,
        name: event.name ?? currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
        isVerified: event.isVerified ?? currentUser.isVerified,
        creditLimit: event.creditLimit ?? currentUser.creditLimit,
        usedLimit: event.usedLimit ?? currentUser.usedLimit,
        limitExpiryDate: event.limitExpiryDate ?? currentUser.limitExpiryDate,
      );
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (event.name != null) {
        await prefs.setString('user_name', event.name!);
      }
      if (event.isVerified != null) {
        await prefs.setBool('isVerified', event.isVerified!);
      }
      if (event.creditLimit != null) {
        await prefs.setDouble('creditLimit', event.creditLimit!);
      }
      if (event.usedLimit != null) {
        await prefs.setDouble('usedLimit', event.usedLimit!);
      }
      if (event.limitExpiryDate != null) {
        await prefs.setString('limitExpiryDate', event.limitExpiryDate!.toIso8601String());
      }
      
      print('DEBUG AuthBloc: Emitting updated user - name: ${updatedUser.name}, verified: ${updatedUser.isVerified}');
      emit(AuthAuthenticated(updatedUser));
    }
  }
}
