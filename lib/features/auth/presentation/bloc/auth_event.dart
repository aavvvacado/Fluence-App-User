import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String phone;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, phone];
}

class AuthRecoveryOptionSelected extends AuthEvent {
  final String method; // 'sms' or 'email'
  const AuthRecoveryOptionSelected({required this.method});

  @override
  List<Object> get props => [method];
}

class AuthResetPasswordWithEmailRequested extends AuthEvent {
  final String email;
  const AuthResetPasswordWithEmailRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthSendPhoneOtpRequested extends AuthEvent {
  final String phoneNumber;
  const AuthSendPhoneOtpRequested({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

// Initiates phone verification for login (sends code and yields verificationId)
class AuthStartPhoneVerificationRequested extends AuthEvent {
  final String phoneNumber;
  const AuthStartPhoneVerificationRequested({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthVerifyPhoneOtpRequested extends AuthEvent {
  final String verificationId;
  final String otp;
  const AuthVerifyPhoneOtpRequested({
    required this.verificationId,
    required this.otp,
  });

  @override
  List<Object> get props => [verificationId, otp];
}

class AuthOtpVerified extends AuthEvent {
  final String otp;
  const AuthOtpVerified({required this.otp});

  @override
  List<Object> get props => [otp];
}

class AuthNewPasswordSet extends AuthEvent {
  final String newPassword;
  const AuthNewPasswordSet({required this.newPassword});

  @override
  List<Object> get props => [newPassword];
}

// Complete profile after first login/signup
class AuthCompleteProfileRequested extends AuthEvent {
  final String name;
  final String phone;
  final String dateOfBirth;
  final String email;
  const AuthCompleteProfileRequested({
    required this.name,
    required this.phone,
    required this.dateOfBirth,
    required this.email,
  });

  @override
  List<Object> get props => [name, phone, dateOfBirth, email];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}