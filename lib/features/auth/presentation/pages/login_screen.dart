import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/shared_preferences_service.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/custom_text_input.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'start_screen.dart';

String _getFailureMessage(Failure failure) {
  if (failure is ServerFailure) return failure.message;
  if (failure is CacheFailure) return failure.message;
  if (failure is InvalidCredentialsFailure) return failure.message;
  if (failure is UserNotFoundFailure) return failure.message;
  if (failure is UnauthorizedAccessFailure) return failure.message;
  return failure.toString();
}

class LoginScreen extends StatefulWidget {
  static const String path = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  List<String> _savedEmails = [];
  String? _selectedEmail;
  String? _emailError;
  bool _dropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmails();
  }

  void _loadSavedEmails() {
    setState(() {
      _savedEmails = SharedPreferencesService.getSavedEmails();
      if (_savedEmails.isNotEmpty) {
        _selectedEmail = _savedEmails.first;
        _emailController.text = _selectedEmail!;
      }
    });
  }

  void _onEmailSelected(String? email) {
    setState(() {
      _selectedEmail = email;
      _emailController.text = email ?? '';
    });
  }

  void _onNext() {
    setState(() {
      _emailError = null;
    });

    // Get the current email value from text controller
    String currentEmail = _emailController.text.trim();

    // Validate email
    if (currentEmail.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(currentEmail)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    // Navigate to password PIN screen
    context.go(
      '/password-pin',
      extra: {'email': currentEmail, 'name': 'User'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GestureDetector(
        // close dropdown on any tap outside
        onTap: () {
          if (_dropdownOpen) setState(() => _dropdownOpen = false);
        },
        child: Stack(
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
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
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
                      // Email input field with dropdown
                      Stack(
                        children: [
                          CustomTextInput(
                            controller: _emailController,
                            hintText: 'Enter your email address',
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                            suffixIcon: _savedEmails.isNotEmpty ? Icons.arrow_drop_down : null,
                            onSuffixIconTap: _savedEmails.isNotEmpty
                                ? () {
                                    setState((){
                                      _dropdownOpen = !_dropdownOpen;
                                    });
                                  }
                                : null,
                          ),
                          if (_dropdownOpen && _savedEmails.isNotEmpty)
                            Positioned(
                              top: 50,
                              left: 0,
                              right: 0,
                              child: Material(
                                elevation: 6.0,
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  children: _savedEmails.map((email){
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: (){
                                        setState((){
                                          _emailController.text = email;
                                          _selectedEmail = email;
                                          _dropdownOpen = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(email, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15)),
                                      ),
                                    );
                                 }).toList(),
                                ),
                              ),
                            ),
                        ],
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
