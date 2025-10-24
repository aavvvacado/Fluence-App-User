import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// The large yellow curved shape seen in the background of most screens
class CurvedBackground extends StatelessWidget {
  const CurvedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedBackgroundClipper(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        color: AppColors.primary,
      ),
    );
  }
}

class _CurvedBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.5);

    // First large wave curve
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.65,
    );

    // Second smaller bump
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.7,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
