import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CashbackEarnedCard extends StatelessWidget {
  final int amount;
  final String currency;

  const CashbackEarnedCard({
    super.key,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = 140.0;
    final leafWidth = screenWidth * 0.15;
    final leafHeight = cardHeight * 0.45;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      width: screenWidth,
      height: cardHeight,
      child: Stack(
        children: [
          // 🟡 Main Card
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Cashback Earned',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${_formatAmount(amount)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🟢 Top Right Leaf
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: leafWidth,
              height: leafHeight,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECAD),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
            ),
          ),

          // 🟡 Bottom Left Leaf
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: leafWidth,
              height: leafHeight,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECAD),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(int amount) {
    if (amount >= 1000) {
      final formatted = (amount / 1000).toStringAsFixed(2);
      return formatted.replaceAll(RegExp(r'\.?0+$'), '') + 'K';
    }
    return amount.toString();
  }
}
