import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/fluence_card.dart';
import '../../../../core/widgets/home_bottom_nav_bar.dart';
import '../../../../core/widgets/profile_header.dart';
import '../../../../core/widgets/social_media_section.dart';

class ProfileScreen extends StatefulWidget {
  static const String path = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Profile tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.black,
                  ),
                ),
              ),

              // Profile Header with user info and stats
              const ProfileHeader(
                userName: 'Romina Carter',
                userEmail: 'sophie123@gmail.com',
                joinDate: 'Joined 2025',
                totalInteractions: 22,
                averageCashback: 158,
                avatarPath: 'assets/images/artist-2 1.png',
              ),
              const SizedBox(height: 16),

              // Fluence Card
              const FluenceCard(points: 7820, backgroundImagePath: null),
              const SizedBox(height: 24),

              // Social Media Profiles Section
              const SocialMediaSection(),
              const SizedBox(height: 120), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: HomeBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            if (index == _selectedIndex) return;
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('QR Scanner')));
                break;
              case 2:
                context.go('/wallet');
                break;
              case 3:
                break;
            }
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}
