import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final SignUp signUp;
  // Other use cases will be injected here (e.g., ResetPassword resetPassword;)

  AuthBloc({
    required this.login,
    required this.signUp,
    // required this.resetPassword,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthRecoveryOptionSelected>(_onRecoveryOptionSelected);
    on<AuthOtpVerified>(_onOtpVerified);
    on<AuthNewPasswordSet>(_onNewPasswordSet);
  }

  // --- Handlers follow SRP/OCP ---

  void _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  void _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        phone: event.phone,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  void _onRecoveryOptionSelected(
    AuthRecoveryOptionSelected event,
    Emitter<AuthState> emit,
  ) async {
    // Simulate use case call: await resetPassword(event.method);
    emit(AuthLoading());
    // Dummy success, skipping repository for simplicity in the flow demo
    await Future.delayed(const Duration(milliseconds: 300));
    emit(RecoveryOptionSelectedState(method: event.method));
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
}
