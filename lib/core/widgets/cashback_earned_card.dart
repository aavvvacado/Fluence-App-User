import 'package:flutter/material.dart';

class CashbackEarnedCard extends StatelessWidget {
  final int amount;
  final String? currency;
  final String? subtitle;
  final String? title;

  const CashbackEarnedCard({
    super.key,
    required this.amount,
    this.currency,
    this.subtitle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = 140.0;
    final cornerWidth = screenWidth * 0.12;
    final cornerHeight = cardHeight * 0.4;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      width: screenWidth,
      height: cardHeight,
      child: Stack(
        children: [
          // 🟡 Main Card - Golden Yellow Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37), // Golden yellow color
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getCardTitle(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCardValue(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 🟡 Top Right Corner Accent
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: cornerWidth,
              height: cornerHeight,
              decoration: const BoxDecoration(
                color: Color(0xFFF4E4A6), // Lighter yellow accent
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
          ),

          // 🟡 Bottom Left Corner Accent
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: cornerWidth,
              height: cornerHeight,
              decoration: const BoxDecoration(
                color: Color(0xFFF4E4A6), // Lighter yellow accent
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCardTitle() {
    if (title != null) {
      return title!;
    }

    if (subtitle != null) {
      return 'Cashback Earned';
    }

    // For different card types based on amount/currency
    if (currency == '%') {
      return 'Cashback Rate';
    } else if (currency == '\$' || currency == '₹' || currency == '€') {
      return 'Total Earned';
    } else if (currency == '0') {
      return 'Total Points';
    }

    return 'Cashback Earned';
  }

  String _getCardValue() {
    if (subtitle != null) {
      if (currency != null) {
        return '$currency${_formatAmount(amount)}';
      } else {
        return '${_formatAmount(amount)}';
      }
    }

    // For different card types
    if (currency == '%') {
      return '${_formatAmount(amount)}%';
    } else if (currency == '0') {
      return '${_formatAmount(amount)} points';
    } else if (currency == null) {
      return '${_formatAmount(amount)}';
    }

    return '$currency${_formatAmount(amount)}';
  }

  static String _formatAmount(int amount) {
    if (amount >= 1000) {
      final formatted = (amount / 1000).toStringAsFixed(2);
      return formatted.replaceAll(RegExp(r'\.?0+$'), '') + 'K';
    }
    return amount.toString();
  }
}
