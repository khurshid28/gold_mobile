import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String otp;
  final String phoneNumber;

  const VerifyOtpRequested(this.otp, this.phoneNumber);

  @override
  List<Object?> get props => [otp, phoneNumber];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
