import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? avatarPath;

  const HomeHeader({super.key, required this.userName, this.avatarPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: avatarPath != null
                  ? Image.asset(
                      avatarPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(width: 16),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName!',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          // Action Icons
          Row(
            children: [
              _buildActionButton(Icons.notifications_active),
              const SizedBox(width: 12),
              _buildActionButton(Icons.card_giftcard_sharp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.lightGrey,
      child: const Icon(Icons.person, color: AppColors.textBody, size: 24),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4), // subtle shadow
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), // horizontal & vertical offset
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.white, size: 20),
    );
  }
}
