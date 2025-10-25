import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/curved_background_clipper.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';
import 'email_recovery_screen.dart';
import 'phone_recovery_screen.dart';

class RecoveryOptionsScreen extends StatefulWidget {
  static const String path = '/recovery-options';
  const RecoveryOptionsScreen({super.key});

  @override
  State<RecoveryOptionsScreen> createState() => _RecoveryOptionsScreenState();
}

class _RecoveryOptionsScreenState extends State<RecoveryOptionsScreen> {
  String _selectedMethod = 'sms';

  void _onNext() {
    if (_selectedMethod == 'email') {
      // Navigate to email recovery screen
      context.go(EmailRecoveryScreen.path);
    } else if (_selectedMethod == 'sms') {
      // Navigate to phone recovery screen
      context.go(PhoneRecoveryScreen.path);
    }
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
                  if (state is RecoveryOptionSelectedState) {
                    context.go('/otp-verification', extra: state.method);
                  }
                },
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Placeholder
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
                    const Text(
                      'Password Recovery',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'How would you like to restore your password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textBody),
                    ),
                    const SizedBox(height: 40),

                    // Option 1: SMS
                    _buildRecoveryOption(
                      icon: Icons.sms,
                      title: 'SMS',
                      isSelected: _selectedMethod == 'sms',
                      onTap: () => setState(() => _selectedMethod = 'sms'),
                    ),
                    const SizedBox(height: 16),

                    // Option 2: Email
                    _buildRecoveryOption(
                      icon: Icons.email,
                      title: 'Email',
                      isSelected: _selectedMethod == 'email',
                      onTap: () => setState(() => _selectedMethod = 'email'),
                    ),

                    const SizedBox(height: 50),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomAppButton(
                          text: 'Next',
                          textStyle: TextStyle(),
                          onPressed: _onNext,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(LoginScreen.path);
                        }
                      },
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

  Widget _buildRecoveryOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.success)
            else
              const Icon(Icons.circle_outlined, color: AppColors.lightGrey),
          ],
        ),
      ),
    );
  }
}
