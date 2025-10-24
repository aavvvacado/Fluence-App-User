import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/curved_background_clipper.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/custom_text_input.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class NewPasswordScreen extends StatefulWidget {
  static const String path = '/new-password';
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  void _onSave() {
    if (_newPasswordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match!')));
      return;
    }
    context.read<AuthBloc>().add(
      AuthNewPasswordSet(newPassword: _newPasswordController.text),
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
                  if (state is PasswordSetSuccess) {
                    context.go(
                      '/ready',
                    ); // Password is set, treat as ready to continue
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.failure.props.first.toString()),
                      ),
                    );
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
                      'Setup New Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please, setup a new password for your password!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textBody),
                    ),
                    const SizedBox(height: 40),

                    CustomTextInput(
                      controller: _newPasswordController,
                      hintText: 'New Password',
                      isPassword: true,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 16),
                    CustomTextInput(
                      controller: _repeatPasswordController,
                      hintText: 'Repeat Password',
                      isPassword: true,
                      prefixIcon: Icons.lock,
                    ),

                    const SizedBox(height: 50),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomAppButton(
                          text: 'Save',
                          textStyle: TextStyle(),
                          onPressed: _onSave,
                          isLoading: state is AuthLoading,
                        );
                      },
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
