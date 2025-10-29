import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletHeader extends StatelessWidget {
  final double height;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final String title;
  final String totalLabel;
  final String totalAmount;

  const WalletHeader({
    super.key,
    required this.height,
    this.onBack,
    this.onMenu,
    this.title = 'My Wallet',
    this.totalLabel = 'TOTAL CASHBACK EARNED',
    this.totalAmount = 'AED 15.00',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.30,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // SVG background provided by design
            SvgPicture.asset(
              'assets/images/Date Selector Container.svg',
              fit: BoxFit.fill,
            ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 65, 25, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                totalLabel,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                totalAmount,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFC48828), Color(0xFFF0CB52)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.credit_card_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@override
Widget _circleButton(IconData icon, VoidCallback? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Color(0xff2C2C2C), size: 18),
    ),
  );
}

// removed decorative circles as the SVG provides the background design
