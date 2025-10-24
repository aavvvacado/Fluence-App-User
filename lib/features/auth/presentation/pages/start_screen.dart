import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_button.dart';

class StartScreen extends StatelessWidget {
  static const String path = '/start';
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Logo Placeholder (Fluence Pay F)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // In a real app, use FlutterSvg here
                      Container(
                        width: 134,
                        height: 134,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(134 / 2, 134 / 2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(
                                0x29000000,
                              ), // #00000029 with hex opacity
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/logo.svg',
                            width: 59,
                            height: 91,
                            // No color override
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFD4AF37), // Lighter gold
                            Color(0xFFC48828), // Deeper gold
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Fluence Pay',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 48.0,
                            letterSpacing: -0.5,
                            height: 1.0,
                            color: Colors.white, // Required by ShaderMask
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'REAL INFLUENCE REAL REWARDS',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight:
                              FontWeight.w500, // Medium/Bold for stronger look
                          fontSize: 13.0,
                          height: 1, // Closer to img, if too tall try 1.1
                          letterSpacing: 0.0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              Column(
                children: [
                  CustomAppButton(
                    text: "Let's get started",
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300, // Light
                      fontSize: 22.0,
                      height: 31 / 22, // Pixel-perfect 31px line-height
                      letterSpacing: 0.0,
                    ),
                    onPressed: () => context.go('/create-account'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'I already have an account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 14.0,
                            height: 26 / 13,
                            letterSpacing: 0.0,
                            color: Color(0xFF202020),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF0056FF), // Blue as in screenshot
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
