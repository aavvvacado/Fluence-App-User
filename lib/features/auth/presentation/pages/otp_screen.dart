import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/curved_background_clipper.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  static const String path = '/otp-verification';
  final String method; // 'sms' or 'email'

  const OtpScreen({super.key, required this.method});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? errorMessage;

  void _onOtpCompleted(String otp) {
    context.read<AuthBloc>().add(AuthOtpVerified(otp: otp));
  }

  void _onSendAgain() {
    // Simulate re-sending the OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent again! (Dummy)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const CurvedBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is OtpVerificationSuccess) {
                    context.go('/new-password');
                  } else if (state is PasswordPinError) {
                    setState(() {
                      errorMessage = state.message;
                    });
                    _otpController.clear();
                  }
                },
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightGrey,
                      child: Text('R', style: TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Password Recovery',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter 4-digits code we sent you on your ${widget.method}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Field
                    PinCodeTextField(
                      appContext: context,
                      length: 4,
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 50,
                        fieldWidth: 50,
                        inactiveColor: AppColors.lightGrey,
                        activeColor: AppColors.primary,
                        selectedColor: AppColors.primary,
                        errorBorderColor: AppColors.error,
                      ),
                      cursorColor: AppColors.primary,
                      animationDuration: const Duration(milliseconds: 150),
                      controller: _otpController,
                      onChanged: (value) {
                        if (errorMessage != null) {
                          setState(() => errorMessage = null);
                        }
                      },
                      onCompleted: _onOtpCompleted,
                    ),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomAppButton(
                          text: 'Send Again',
                          textStyle: TextStyle(),
                          onPressed: _onSendAgain,
                          isPrimary: false,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textBody),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
