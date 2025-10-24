import 'dart:ui';

import 'package:fluence/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onTap;

  const HomeBottomNavBar({super.key, required this.selectedIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92, // 72 + 20 bottom padding
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      child: Center(
        child: Container(
          width: 364,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(icon: Icons.home_rounded, index: 0),
                    _buildQRScanButton(),
                    _buildNavItem(
                      icon: Icons.account_balance_wallet_rounded,

                      index: 2,
                    ),
                    _buildNavItem(icon: Icons.person_rounded, index: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRScanButton() {
    return GestureDetector(
      onTap: () => onTap?.call(1),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4A200), Color(0xFFB88F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.primary)],
        ),
        child: const Center(
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.primary,
              size: 35,
            ),
            const SizedBox(height: 2),

            const SizedBox(height: 2),
            // Indicator dot
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4A200)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
