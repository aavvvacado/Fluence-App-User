import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_button.dart';

class ReadyScreen extends StatelessWidget {
  static const String path = '/ready';
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Yellow bubble top left
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/bubble_ready1.svg',
              width: 400,
              height: 442,
            ),
          ),
          // Blue bubble bottom right
          Positioned(
            top: 340.16,
            left: 66.19,
            child: Transform.rotate(
              angle: -108 * (3.14159 / 180), // Convert degrees to radians
              child: Opacity(
                opacity: 1.0,
                child: SvgPicture.asset(
                  'assets/images/bubble_ready2.svg',
                  width: 377.0185641479105,
                  height: 442.6496693103966,
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 The white card
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.symmetric(vertical: 60),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Image.asset(
                          'assets/images/ready.png',
                          height: 320,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              'Ready?',
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: "Poppins",
                                color: AppColors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 40),
                            CustomAppButton(
                              text: "Let's Start",
                              onPressed: () {
                                context.go('/home');
                              },
                              textStyle: const TextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 Dots moved outside the card
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(false),
                    const SizedBox(width: 8),
                    _buildDot(false),
                    const SizedBox(width: 8),
                    _buildDot(false),
                    const SizedBox(width: 8),
                    _buildDot(true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : Color(0xffC7D6FB),
      ),
    );
  }
}
