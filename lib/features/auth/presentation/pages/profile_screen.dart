import 'package:fluence/features/auth/presentation/pages/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/shared_preferences_service.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/fluence_card.dart';
import '../../../../core/widgets/home_bottom_nav_bar.dart';
import '../../../../core/widgets/profile_header.dart';
import '../../../../core/widgets/social_media_section.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  static const String path = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Profile tab

  void _onLogout() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('[ProfileScreen] AuthBloc state: $state');
        if (state is AuthLogoutSuccess) {
          print(
            '[ProfileScreen] Logout success, navigating to start screen...',
          );
          context.go(StartScreen.path);
        }
      },
      child: Scaffold(
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
                Builder(
                  builder: (context) {
                    final name =
                        SharedPreferencesService.getUserName() ??
                        'Romina Carter';
                    final email =
                        SharedPreferencesService.getUserEmail() ??
                        'sophie123@gmail.com';
                    final phone = SharedPreferencesService.getProfilePhone();
                    return Column(
                      children: [
                        ProfileHeader(
                          userName: name,
                          userEmail: email,
                          joinDate: 'Joined 2025',
                          totalInteractions: 22,
                          averageCashback: 158,
                          avatarPath: 'assets/images/artist-2 1.png',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Fluence Card
                const FluenceCard(points: 7820, backgroundImagePath: null),
                const SizedBox(height: 24),

                // Social Media Profiles Section
                const SocialMediaSection(),
                const SizedBox(height: 24),

                // Logout Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomAppButton(
                        text: 'Logout',
                        textStyle: const TextStyle(
                          color:
                              Colors.red, // You can adjust color for the text
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        isPrimary: false,
                        onPressed: state is AuthLoading ? null : _onLogout,
                        isLoading: state is AuthLoading,
                        // backgroundColor property removed: not a valid argument
                      ),
                    );
                  },
                ),
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
      ),
    );
  }
}
