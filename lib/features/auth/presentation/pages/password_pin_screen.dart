import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/shared_preferences_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PasswordPinScreen extends StatefulWidget {
  static const String path = '/password-pin';
  final String email;
  final String name;

  const PasswordPinScreen({super.key, required this.email, required this.name});

  @override
  State<PasswordPinScreen> createState() => _PasswordPinScreenState();
}

class _PasswordPinScreenState extends State<PasswordPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? errorMessage;

  void _onPinCompleted(String pin) {
    // In a real flow, we would use the stored password PIN here.
    // Since we are simulating, we use the credentials from the dummy data source.
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: widget.email,
        // Using '1234' as the dummy PIN/password based on the dummy DS
        password: pin,
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
          // Background bubbles (matching login screen)
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: BlocListener<AuthBloc, AuthState>(
                 listener: (context, state) {
                   if (state is AuthAuthenticated) {
                     // Save email to shared preferences on successful login
                     SharedPreferencesService.saveEmail(widget.email);
                     context.go('/ready');
                   } else if (state is AuthError) {
                     // Simulating the "06 Wrong Password" state
                     setState(() {
                       errorMessage = 'Wrong Password. Try again.';
                     });
                     _pinController.clear();
                   }
                 },
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    // User avatar (artist-2 1.svg)
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white, // Light blue border
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
                            color: Colors.white, // White background
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Image.asset(
                                'assets/images/artist-2 1.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: const Color(0xFFE8E8E8),
                                      child: const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Hello, ${widget.name}!',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Type your password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // PIN Code Input (8-dots) - Wrapped for tighter spacing
                    Transform.scale(
                      scale: 0.8, // Scale down to bring dots closer
                      child: PinCodeTextField(
                        appContext: context,
                        length: 8, // 👈 8 digits
                        obscureText: false, // Show filled circles without text
                        animationType: AnimationType.fade,
                        enableActiveFill:
                            true, // 👈 REQUIRED to avoid RangeError
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          fieldHeight: 17,
                          fieldWidth: 17, // Even tighter spacing between dots
                          inactiveColor: Color(0xffE5EBFC),
                          activeColor: AppColors.primary,
                          selectedColor: Color(0xffE5EBFC),
                          errorBorderColor: AppColors.error,
                          inactiveFillColor: Color(0xffE5EBFC),
                          activeFillColor: AppColors.primary,
                          selectedFillColor: Color(0xffE5EBFC),
                        ),
                        textStyle: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 0,
                        ),
                        cursorColor: AppColors.primary,
                        animationDuration: const Duration(milliseconds: 150),
                        controller: _pinController,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        onCompleted: _onPinCompleted,
                      ),
                    ),

                    // Error/Wrong Password State (06 Wrong Password)
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

                    TextButton(
                      onPressed: () {
                        context.go(
                          '/recovery-options',
                        ); // or use RecoveryOptionsScreen.path if imported
                      },
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/login');
                        }
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    // Keyboard spacer
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 100,
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
