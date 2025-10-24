import 'package:fluence/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String joinDate;
  final int totalInteractions;
  final double averageCashback;
  final String? avatarPath;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.joinDate,
    required this.totalInteractions,
    required this.averageCashback,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main card
              Container(
                margin: const EdgeInsets.only(top: 60),
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // User Name
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Join Date
                    Text(
                      joinDate,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            value: totalInteractions.toString(),
                            label: 'Total interactions',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _StatItem(
                            value: '\$${averageCashback.toInt()}',
                            label: 'Average Cashback',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Avatar positioned at top
              Positioned(
                top: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC0CB), // Pink background
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarPath != null
                        ? Image.asset(
                            avatarPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              );
                            },
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
