import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomAppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;

  const CustomAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    required TextStyle textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPrimary && !isLoading ? [] : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primaryDark : AppColors.white,
          foregroundColor: isPrimary ? AppColors.white : AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  color: isPrimary ? AppColors.white : AppColors.primary,
                ),
              ),
      ),
    );
  }
}
