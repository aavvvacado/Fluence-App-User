import 'package:fluence/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/custom_text_input.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  static const String path = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: 'test@fluence.com',
  );

  void _onNext() {
    // The design only shows email/phone input here, then transitions to PIN screen.
    // We pass the email/phone along to the PIN screen for context.
    context.go(
      '/password-pin',
      extra: {'email': _emailController.text, 'name': 'Romina'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background bubbles
          Positioned(
            top: -171.68,
            left: -136.68,
            child: Transform.rotate(
              angle: -110 * (3.14159 / 180), // Convert degrees to radians
              child: SvgPicture.asset(
                'assets/images/bubble2 _login.svg',
                width: 373.53,
                height: 442.65,
              ),
            ),
          ),
          Positioned(
            top: -171,
            left: -158.44,
            child: SvgPicture.asset(
              'assets/images/bubble1_login.svg',
              width: 402.87,
              height: 442.65,
            ),
          ),
          // Bro illustration
          Positioned(
            top: 155,
            left: 48,
            child: Opacity(
              opacity: 0.75,
              child: SvgPicture.asset(
                'assets/images/bro.svg',
                width: 246,
                height: 250.78,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Bubble 3
          Positioned(
            top: 239.24,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/bubblle 03.svg',
              width: 137.56,
              height: 151.14,
            ),
          ),
          Positioned(
            top: 449.48,
            left: 87.19,

            child: SvgPicture.asset(
              'assets/images/bubblle 04.svg',
              width: 373.53,
              height: 442.65,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 450,
                  ), // ensure content is below bro.svg
                  // Heading
                  Text(
                    'Login',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 52,
                      color: AppColors.black,
                      height: 1.16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Good to see you back! 🖤',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textBody,
                    ),
                  ),
                  const SizedBox(height: 36),
                  CustomTextInput(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    suffixIcon: Icons.keyboard_arrow_down_rounded,
                  ),
                  const SizedBox(height: 36),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomAppButton(
                        text: 'Next',
                        textStyle: const TextStyle(),
                        onPressed: _onNext,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textBody,
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
          ),
        ],
      ),
    );
  }
}
