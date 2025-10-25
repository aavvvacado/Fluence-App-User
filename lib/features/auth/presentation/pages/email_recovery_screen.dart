import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/curved_background_clipper.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/custom_text_input.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

String _getFailureMessage(failure) {
  if (failure is ServerFailure) return failure.message;
  if (failure is CacheFailure) return failure.message;
  if (failure is InvalidCredentialsFailure) return failure.message;
  if (failure is UserNotFoundFailure) return failure.message;
  if (failure is UnauthorizedAccessFailure) return failure.message;
  return failure.toString();
}

class EmailRecoveryScreen extends StatefulWidget {
  static const String path = '/email-recovery';
  const EmailRecoveryScreen({super.key});

  @override
  State<EmailRecoveryScreen> createState() => _EmailRecoveryScreenState();
}

class _EmailRecoveryScreenState extends State<EmailRecoveryScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  void _onSendResetEmail() {
    setState(() {
      _emailError = null;
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    context.read<AuthBloc>().add(
      AuthResetPasswordWithEmailRequested(email: _emailController.text.trim()),
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
                  if (state is EmailPasswordResetSent) {
                    // Show success message and pop/go to login safely
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset email sent to ${state.email}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Prevent 'nothing to pop' GoError:
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
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
                                Icons.email,
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
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textBody),
                    ),
                    const SizedBox(height: 40),

                    // Email input
                    CustomTextInput(
                      controller: _emailController,
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),

                    const SizedBox(height: 50),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomAppButton(
                          text: 'Send Reset Email',
                          textStyle: const TextStyle(),
                          onPressed: _onSendResetEmail,
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
    _emailController.dispose();
    super.dispose();
  }
}
