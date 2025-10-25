import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/curved_background_clipper.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

String _getFailureMessage(failure) {
  if (failure is ServerFailure) return failure.message;
  if (failure is CacheFailure) return failure.message;
  if (failure is InvalidCredentialsFailure) return failure.message;
  if (failure is UserNotFoundFailure) return failure.message;
  return failure.toString();
}

class PhoneRecoveryScreen extends StatefulWidget {
  static const String path = '/phone-recovery';
  const PhoneRecoveryScreen({super.key});

  @override
  State<PhoneRecoveryScreen> createState() => _PhoneRecoveryScreenState();
}

class _PhoneRecoveryScreenState extends State<PhoneRecoveryScreen> {
  final _phoneController = TextEditingController();
  String? _phoneError;
  String countryCode = '+91'; // default to India

  void _onSendOtp() {
    setState(() {
      _phoneError = null;
    });

    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _phoneError = 'Please enter your phone number';
      });
      return;
    }

    final fullPhoneNumber = countryCode + _phoneController.text.trim();
    
    context.read<AuthBloc>().add(
      AuthSendPhoneOtpRequested(phoneNumber: fullPhoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const CurvedBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is PhoneOtpSent) {
                    // Navigate to OTP verification screen
                    context.go('/otp-verification', extra: {
                      'method': 'phone',
                      'phoneNumber': state.phoneNumber,
                      'verificationId': state.verificationId,
                    });
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_getFailureMessage(state.failure)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Profile Placeholder
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white,
                            child: const Center(
                              child: Icon(
                                Icons.phone,
                                size: 50,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your phone number and we\'ll send you an OTP to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textBody),
                    ),
                    const SizedBox(height: 40),

                    // Phone input with country picker
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.textfield,
                        borderRadius: BorderRadius.circular(59.29),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          CountryCodePicker(
                            onChanged: (code) { 
                              setState(() {
                                countryCode = code.dialCode ?? '+91';
                              });
                            },
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                            showFlag: true,
                            showCountryOnly: true,
                            showOnlyCountryWhenClosed: false,
                            showDropDownButton: true,
                            hideMainText: true,
                            alignLeft: false,
                            flagWidth: 25,
                            padding: EdgeInsets.zero,
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: const Color(0xff1f1f1f),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.darkGrey,
                                fontFamily: 'Poppins',
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Your number',
                                hintStyle: const TextStyle(
                                  color: Color(0xffD2D2D2),
                                  fontFamily: 'Poppins',
                                ),
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                                errorText: _phoneError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomAppButton(
                          text: 'Send OTP',
                          textStyle: const TextStyle(),
                          onPressed: _onSendOtp,
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
