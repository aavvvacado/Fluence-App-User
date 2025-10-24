import 'package:flutter/material.dart';

// Assuming AppColors is available
import '../constants/app_colors.dart';

// Placeholder for AppColors for code completeness
// class AppColors {
//   static const Color primary = Color(0xFFC48828);
//   static const Color black = Colors.black87;
//   static const Color textBody = Colors.grey;
//   static const Color success = Colors.green;
//   static const Color lightGrey = Color(0xFFF0F0F0);
//   static const Color unfilled = Color(0xFFF7F7F7);
// }

class SocialMediaSection extends StatelessWidget {
  const SocialMediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Section Title and Description (Unchanged)
          const Text(
            'Social Media Profiles',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff111111),
            ),
          ),
          const SizedBox(height: 8),

          // Description (Unchanged)
          Text(
            'Link your profiles to boost your Fluence Score and unlock higher cashback rates',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff111111),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // 2. The list of separate containers (Individual cards)
          // The main container structure is removed, replaced by direct item listing
          _SocialMediaItem(
            imagePath: 'assets/coffee_club_logo.png',
            platform: 'Instagram',
            isLinked: false,
            onTap: () {},
          ),
          // Added vertical space to separate the cards
          const SizedBox(height: 12),

          _SocialMediaItem(
            imagePath: 'assets/coffee_club_logo.png',
            platform: 'Facebook',
            isLinked: false,
            onTap: () {},
          ),
          // Added vertical space to separate the cards
          const SizedBox(height: 12),

          _SocialMediaItem(
            imagePath: 'assets/coffee_club_logo.png',
            platform: 'Twitter',
            isLinked: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// =================================================================
// === REFACTORED _SocialMediaItem to be a self-contained card ===
// =================================================================

class _SocialMediaItem extends StatelessWidget {
  final String imagePath;
  final String platform;
  final bool isLinked;
  final VoidCallback onTap;

  const _SocialMediaItem({
    required this.imagePath,
    required this.platform,
    required this.isLinked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // CRITICAL FIX: The decoration is moved here to make it a separate card
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        // Added border/shadow from the original image style
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6), // #00000040 → 25% opacity
            blurRadius: 10,
            spreadRadius: -4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        // Using ClipRRect to ensure the InkWell splash effect respects the rounded corners
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 1. Platform Logo/Image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xffDCDCDC),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.link,
                        size: 20,
                        color: AppColors.textBody,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 2. Platform Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLinked ? 'Linked' : 'Not linked',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isLinked ? AppColors.success : Color(0xff868686),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Link Button (Plus Icon)
              Container(
                width: 28, // smaller circle
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white, // white background
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary, // circle border color
                    width: 2, // thickness of border
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary, // plus color
                  size: 16, // smaller icon
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
