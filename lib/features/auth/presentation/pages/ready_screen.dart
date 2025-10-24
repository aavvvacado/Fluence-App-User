import 'package:flutter/material.dart';
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
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.only(top: 100),
          padding: const EdgeInsets.all(30),
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
            children: [
              // Image Placeholder (Cashback illustration)
              Container(
                height: 200,
                width: 200,
                color: AppColors.primary.withOpacity(0.3),
                child: const Center(
                  child: Text(
                    'Cashback SVG Placeholder',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Ready?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textBody),
              ),
              const SizedBox(height: 40),
              CustomAppButton(
                text: "Let's Start",
                onPressed: () {
                  // Final navigation to the main application dashboard
                  context.go('/home');
                },
                textStyle: TextStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
