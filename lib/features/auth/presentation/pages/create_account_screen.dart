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
import 'ready_screen.dart';

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

  // ✅ Checkboxes
  bool _agreeAuthInfo = false;
  bool _agreePrivacy = false;

  void _onSignUp() {
    setState(() {
      passError = null;
    });
    if (_passwordController.text.length != 8) {
      setState(() {
        passError = 'Password must be exactly 8 characters';
      });
      return;
    }
    // Save temp details for profile prefill
    final combinedPhone = countryCode + _phoneController.text.trim();
    SharedPreferencesService.saveTempSignupEmail(_emailController.text.trim());
    SharedPreferencesService.saveTempSignupPhone(combinedPhone);

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: combinedPhone,
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
                  // illustration behind inputs
                  Positioned(
                    top: 251,
                    left: 20,
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

                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      if (state is AuthSignUpSuccess) {
                        SharedPreferencesService.saveEmail(
                          _emailController.text.trim(),
                        );
                        await SharedPreferencesService.clearGuestSession();
                        context.go(ReadyScreen.path);
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
                            child: Text(
                              passError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Phone field with country picker
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your number',
                                    hintStyle: TextStyle(
                                      color: Colors.black45,
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

                        const SizedBox(height: 40),

                        // ✅ Checkboxes section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'The information you provide during login will be used solely for authentication and improving your app experience.',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.black,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: _agreeAuthInfo,

                              checkColor: Colors.white, // tick color
                              side: const BorderSide(
                                // border when unchecked or checked
                                color: AppColors.primaryDark,
                                width: 3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _agreeAuthInfo = val ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'We do not sell, trade, or share your personal data with third parties.',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.black,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: _agreePrivacy,

                              checkColor: Colors.white, // tick color
                              side: const BorderSide(
                                // border when unchecked or checked
                                color: AppColors.primaryDark,
                                width: 3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _agreePrivacy = val ?? false;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ✅ Done button (only active when both boxes checked)
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final canProceed = _agreeAuthInfo && _agreePrivacy;
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: (state is AuthLoading || !canProceed)
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

                        const SizedBox(height: 16),

                        // ✅ Terms & Privacy clickable text
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'By continuing, you agree to our ',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: navigate to Terms of Service
                                },
                                child: const Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Text(
                                ' and ',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: navigate to Privacy Policy
                                },
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
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
