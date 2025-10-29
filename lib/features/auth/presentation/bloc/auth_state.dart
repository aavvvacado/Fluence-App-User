import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final Failure failure;
  const AuthError({required this.failure});

  @override
  List<Object> get props => [failure];
}

// Specific states for the flow
class PasswordPinError extends AuthState {
  final String message;
  const PasswordPinError({required this.message});

  @override
  List<Object> get props => [message];
}

class RecoveryOptionSelectedState extends AuthState {
  final String method;
  const RecoveryOptionSelectedState({required this.method});

  @override
  List<Object> get props => [method];
}

class EmailPasswordResetSent extends AuthState {
  final String email;
  const EmailPasswordResetSent({required this.email});

  @override
  List<Object> get props => [email];
}

class PhoneOtpSent extends AuthState {
  final String phoneNumber;
  final String verificationId;
  const PhoneOtpSent({
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  List<Object> get props => [phoneNumber, verificationId];
}

class OtpVerificationSuccess extends AuthState {}

class PasswordSetSuccess extends AuthState {}

class ProfileCompletionInProgress extends AuthState {}
class ProfileCompletionSuccess extends AuthState {}

class AuthLogoutSuccess extends AuthState {}

class AuthSignUpSuccess extends AuthState {
  final UserEntity user;
  const AuthSignUpSuccess({required this.user});
  @override
  List<Object> get props => [user];
}