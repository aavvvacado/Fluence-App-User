import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/phone_verification_service.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/reset_password_with_email.dart';
import '../../domain/usecases/send_phone_otp.dart';
import '../../domain/usecases/verify_phone_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final SignUp signUp;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ResetPasswordWithEmail resetPasswordWithEmail;
  final SendPhoneOtp sendPhoneOtp;
  final VerifyPhoneOtp verifyPhoneOtp;

  AuthBloc({
    required this.login,
    required this.signUp,
    required this.logout,
    required this.getCurrentUser,
    required this.resetPasswordWithEmail,
    required this.sendPhoneOtp,
    required this.verifyPhoneOtp,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthRecoveryOptionSelected>(_onRecoveryOptionSelected);
    on<AuthResetPasswordWithEmailRequested>(_onResetPasswordWithEmailRequested);
    on<AuthSendPhoneOtpRequested>(_onSendPhoneOtpRequested);
    on<AuthVerifyPhoneOtpRequested>(_onVerifyPhoneOtpRequested);
    on<AuthOtpVerified>(_onOtpVerified);
    on<AuthNewPasswordSet>(_onNewPasswordSet);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  // --- Handlers follow SRP/OCP ---

  void _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('[AuthBloc] Login Requested: ${event.email}');
    emit(AuthLoading());
    final result = await login(
      LoginParams(email: event.email, password: event.password),
    );
    print('[AuthBloc] Login result: $result');
    result.fold(
      (failure) {
        print('[AuthBloc] Login Failure: $failure');
        emit(AuthError(failure: failure));
      },
      (user) {
        print('[AuthBloc] Login Success: User ${user.email}');
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  void _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('[AuthBloc] SignUp Requested: ${event.email}');
    emit(AuthLoading());
    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        phone: event.phone,
      ),
    );
    print('[AuthBloc] SignUp result: $result');
    result.fold(
      (failure) {
        print('[AuthBloc] SignUp Failure: $failure');
        emit(AuthError(failure: failure));
      },
      (user) {
        print('[AuthBloc] SignUp Success: User ${user.email}');
        emit(AuthSignUpSuccess(user: user));
      },
    );
  }

  void _onRecoveryOptionSelected(
    AuthRecoveryOptionSelected event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(RecoveryOptionSelectedState(method: event.method));
  }

  void _onResetPasswordWithEmailRequested(
    AuthResetPasswordWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resetPasswordWithEmail(event.email);
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (_) => emit(EmailPasswordResetSent(email: event.email)),
    );
  }

  void _onSendPhoneOtpRequested(
    AuthSendPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await sendPhoneOtp(event.phoneNumber);
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (_) {
        final verificationId = PhoneVerificationService.verificationId;
        if (verificationId != null) {
          emit(PhoneOtpSent(
            phoneNumber: event.phoneNumber,
            verificationId: verificationId,
          ));
        } else {
          emit(AuthError(failure: ServerFailure(message: 'Failed to get verification ID')));
        }
      },
    );
  }

  void _onVerifyPhoneOtpRequested(
    AuthVerifyPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyPhoneOtp(event.verificationId, event.otp);
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (_) => emit(OtpVerificationSuccess()),
    );
  }

  void _onOtpVerified(AuthOtpVerified event, Emitter<AuthState> emit) async {
    // Simulate use case call: await verifyOtp(event.otp);
    emit(AuthLoading());
    if (event.otp == '1234') {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(OtpVerificationSuccess());
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(
        PasswordPinError(message: 'The code is incorrect.'),
      ); // Re-using PinError for OTP
    }
  }

  void _onNewPasswordSet(
    AuthNewPasswordSet event,
    Emitter<AuthState> emit,
  ) async {
    // Simulate use case call: await setNewPassword(event.newPassword);
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(PasswordSetSuccess());
  }

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('[AuthBloc] Logout Requested');
    emit(AuthLoading());
    final result = await logout();
    print('[AuthBloc] Logout result: $result');
    result.fold(
      (failure) {
        print('[AuthBloc] Logout Failure: $failure');
        emit(AuthError(failure: failure));
      },
      (_) {
        print('[AuthBloc] Logout Success');
        emit(AuthLogoutSuccess());
      },
    );
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
}
