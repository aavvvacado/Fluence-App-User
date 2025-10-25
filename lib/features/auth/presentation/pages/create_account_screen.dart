import 'package:country_code_picker/country_code_picker.dart';
import 'package:fluence/features/auth/presentation/pages/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/shared_preferences_service.dart';
import '../../../../core/widgets/custom_text_input.dart';
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

class CreateAccountScreen extends StatefulWidget {
  static const String path = '/create-account';
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? passError;
  String countryCode = '+91'; // default to India

  void _onSignUp() {
    setState(() {passError = null;});
    if (_passwordController.text.length != 8) {
      setState(() {
        passError = 'Password must be exactly 8 characters';
      });
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: countryCode + _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // background bubbles
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/bubble 02.svg',
              width: 311,
              height: 280,
            ),
          ),
          Positioned(
            top: 60,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/bubble 01.svg',
              width: 243,
              height: 266,
            ),
          ),

          // main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  // --- Positioned illustration behind input fields ---
                  Positioned(
                    top: 251, // precise top offset
                    left: 20, // precise left offset
                    child: Opacity(
                      opacity: 0.54,
                      child: SvgPicture.asset(
                        'assets/images/rafiki.svg',
                        width: 333.28,
                        height: 285.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // --- Foreground content ---
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      print('[CreateAccountScreen] AuthBloc state: $state');
                      if (state is AuthSignUpSuccess) {
                        print(
                          '[CreateAccountScreen] Signup success, redirecting to login screen.',
                        );
                        // Save email to shared preferences
                        SharedPreferencesService.saveEmail(_emailController.text.trim());
                        context.go('/login');
                      } else if (state is AuthError) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_getFailureMessage(state.failure)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isSmall ? 140 : 180),
                        SizedBox(
                          width: 300,
                          child: const Text(
                            'Create\nAccount',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 50.0,
                              color: AppColors.black,
                              height: 1.15,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),

                        // Email field
                        CustomTextInput(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        CustomTextInput(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                        ),
                        if (passError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, top: 4),
                            child: Text(passError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Phone field, with country picker prefix
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.textfield,
                            borderRadius: BorderRadius.circular(
                              59.29,
                            ), // your exact radius
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              CountryCodePicker(
                                onChanged: (code) { setState((){countryCode = code.dialCode ?? '+91';}); },
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
                                color: Color(0xff1f1f1f),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              // phone number input
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.darkGrey,
                                    fontFamily: 'Poppins',
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your number',
                                    hintStyle: TextStyle(
                                      color: Color(0xffD2D2D2),
                                      fontFamily: 'Poppins',
                                    ),
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Done button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : _onSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        'Done',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // Cancel button
                        Center(
                          child: TextButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(StartScreen.path);
                              }
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.black,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone number input (SRP isolated widget)
class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.darkGrey,
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        hintText: 'Your number',
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xffD2D2D2),
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: AppColors.textfield,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(59.29),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(59.29),
          borderSide: const BorderSide(color: AppColors.textfield),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: Color(0xff1f1f1f),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 30, color: Color(0xff1f1f1f)),
              const SizedBox(width: 8),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
