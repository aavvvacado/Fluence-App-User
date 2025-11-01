import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletHeader extends StatelessWidget {
  final double height;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final String title;
  final double titleFontSize;
  final String totalLabel;
  final String totalAmount;

  const WalletHeader({
    super.key,
    required this.height,
    this.onBack,
    this.onMenu,
    this.title = 'My Wallet',
    this.titleFontSize = 20,
    this.totalLabel =
        '  Great job!\nYour 250 points can unlock 150\ncashback on exciting offers',
    this.totalAmount = '',
  });

  @override
  Widget build(BuildContext context) {
    // Use the provided height and scale paddings/fonts responsively
    final double headerHeight = height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool veryCompact = headerHeight < 160;
    final bool compact = headerHeight < 180;
    final double topPadding = (headerHeight * 0.20).clamp(12.0, 40.0);
    final double sidePadding = compact ? 20.0 : 25.0;
    final double bottomPadding = (headerHeight * 0.05).clamp(6.0, 14.0);
    final double messageFontSize = (headerHeight * 0.10)
        .clamp(11.0, 18.0)
        .clamp(11.0, screenWidth * 0.045);
    final int messageMaxLines = veryCompact ? 1 : (compact ? 2 : 3);
    final double badgeSize = (headerHeight * 0.36).clamp(40.0, 56.0);
    final double badgeIconSize = (badgeSize * 0.54).clamp(18.0, 30.0);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: SizedBox(
        width: double.infinity,
        height: headerHeight,
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
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  topPadding,
                  sidePadding,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
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
                                maxLines: messageMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: messageFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: badgeSize,
                          height: badgeSize,
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
                          child: Icon(
                            Icons.credit_card_rounded,
                            color: Colors.white,
                            size: badgeIconSize,
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
