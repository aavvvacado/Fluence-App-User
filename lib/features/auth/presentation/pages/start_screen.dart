import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../guest/bloc/guest_bloc.dart';

class StartScreen extends StatelessWidget {
  static const String path = '/start';
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return BlocListener<GuestBloc, GuestState>(
      listener: (context, state) {
        if (state is GuestAuthenticated) {
          context.go('/home');
        } else if (state is GuestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Top spacing (roughly 15% of screen height)
                SizedBox(height: height * 0.15),

                // Logo + Texts
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 134,
                      height: 134,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(67),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x29000000),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: 59,
                          height: 91,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFC48828)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'Fluence Pay',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 48.0,
                          letterSpacing: -0.5,
                          height: 1.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'REAL INFLUENCE REAL REWARDS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.0,
                        height: 1.2,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Spacer pushes buttons to bottom nicely
                const Spacer(),

                // Buttons section
                Column(
                  children: [
                    CustomAppButton(
                      text: "Let's get started",
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        fontSize: 22.0,
                        height: 31 / 22,
                        letterSpacing: 0.0,
                      ),
                      onPressed: () => context.go('/create-account'),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => context.go('/login'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'I already have an account',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14.0,
                                  color: Color(0xFF202020),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<GuestBloc, GuestState>(
                          builder: (context, state) {
                            final isLoading = state is GuestLoading;
                            return TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      final deviceId = UniqueKey().toString();
                                      context
                                          .read<GuestBloc>()
                                          .add(GuestLoginRequested(deviceId));
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(
                                      'Browse as a guest',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14.0,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                        decorationThickness: 1.2,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                // Bottom spacing (roughly 8% of screen height)
                SizedBox(height: height * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
