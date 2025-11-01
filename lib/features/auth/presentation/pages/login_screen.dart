import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/shared_preferences_service.dart';
import '../../../../core/widgets/custom_app_button.dart';
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
  final TextEditingController _inputController = TextEditingController();
  String _selectedAuthOption = 'Email';
  String _countryCode = '+91';
  String? _errorText;

  void _onNext() {
    setState(() => _errorText = null);

    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(
        () => _errorText = 'Please enter ${_selectedAuthOption.toLowerCase()}',
      );
      return;
    }

    if (_selectedAuthOption == 'Email') {
      final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(input)) {
        setState(() => _errorText = 'Please enter a valid email address');
        return;
      }

      // Get user name for this specific email from SharedPreferences
      final userName = SharedPreferencesService.getUserNameForEmail(input) ?? 'User';
      print('[LoginScreen] Email: $input, UserName: $userName');
      context.go('/password-pin', extra: {'email': input, 'name': userName});
    } else {
      final phone = '$_countryCode$input';
      context.read<AuthBloc>().add(
        AuthStartPhoneVerificationRequested(phoneNumber: phone),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BlocListener<AuthBloc, AuthState>(
                listener: _authListener,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 450),
                    _buildHeading(),
                    const SizedBox(height: 36),
                    _buildCombinedInput(),
                    if (_errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 8),
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 36),
                    _buildNextButton(),
                    const SizedBox(height: 16),
                    _buildCancelButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -171,
          left: -158.44,
          child: SvgPicture.asset(
            'assets/images/bubble1_login.svg',
            width: 402.87,
            height: 442.65,
          ),
        ),
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
      ],
    );
  }

  Widget _buildHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 52,
            color: AppColors.black,
            height: 1.16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Good to see you back! 🖤',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedInput() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.textfield,
        borderRadius: BorderRadius.circular(59.29),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Country code picker for phone (only when Phone is selected) - LEFT SIDE
          if (_selectedAuthOption == 'Phone') ...[
            CountryCodePicker(
              onChanged: (code) =>
                  setState(() => _countryCode = code.dialCode ?? '+91'),
              initialSelection: 'IN',
              favorite: const ['+91', 'IN'],
              showFlag: true,
              showDropDownButton: true,
              hideMainText: true,
              flagWidth: 25,
              padding: EdgeInsets.zero,
            ),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.shade400,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
          // Input field with Email as default hint
          Expanded(
            child: TextField(
              controller: _inputController,
              keyboardType: _selectedAuthOption == 'Email'
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _selectedAuthOption == 'Email'
                    ? 'Email'
                    : 'Phone Number',
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),
          // Auth option selector (opens bottom sheet instead of cramped dropdown)
          IconButton(
            onPressed: _showAuthOptionPicker,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.darkGrey,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthOptionPicker() async {
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Login with',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                  title: const Text('Email', style: TextStyle(fontFamily: 'Poppins')),
                  onTap: () => Navigator.of(context).pop('Email'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  title: const Text('Phone Number', style: TextStyle(fontFamily: 'Poppins')),
                  onTap: () => Navigator.of(context).pop('Phone'),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && picked != _selectedAuthOption) {
      setState(() {
        _selectedAuthOption = picked;
        _inputController.clear();
        _errorText = null;
      });
    }
  }

  Widget _buildNextButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomAppButton(
          text: _selectedAuthOption == 'Email' ? 'Next' : 'Send Code',
          onPressed: _onNext,
          isLoading: state is AuthLoading,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(StartScreen.path),
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
    );
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state is PhoneOtpSent) {
      context.go(
        '/otp-verification',
        extra: {
          'method': 'phone',
          'phoneNumber': state.phoneNumber,
          'verificationId': state.verificationId,
        },
      );
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getFailureMessage(state.failure)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
