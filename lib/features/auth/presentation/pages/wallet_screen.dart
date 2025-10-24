import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/home_bottom_nav_bar.dart';
import '../../../../core/widgets/wallet_header.dart';

class WalletScreen extends StatefulWidget {
  static const String path = '/wallet';

  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedIndex = 2; // Wallet tab

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.sizeOf(context).height * 0.24;
    final double panelTopPosition = headerHeight - 60;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Header - Fixed at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WalletHeader(
              height: headerHeight,
              onBack: () => context.go('/home'),
              onMenu: () {},
            ),
          ),

          // Scrollable content area - starts below header
          Positioned(
            top: panelTopPosition,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // StatsPanel with horizontal padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _StatsPanel(),
                  ),
                  const SizedBox(height: 20),

                  // Filters and List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _FiltersAndList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
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
                break;
              case 3:
                context.go('/profile');
                break;
            }
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}

// =================== Widgets ===================

class _StatsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _rowItem(
            context,
            icon: Icons.calendar_month_rounded,
            title: 'PERIOD EARNED',
            trailing: _pill('AED 0.00'),
          ),
          const SizedBox(height: 12),
          _rowItem(
            context,
            icon: Icons.timelapse_rounded,
            title: 'PENDING',
            trailing: _pill('AED 0.00'),
          ),
          const SizedBox(height: 12),
          _rowItem(
            context,
            icon: Icons.compare_arrows_rounded,
            title: 'TRANSACTIONS',
            trailing: _pill('0'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Post about your purchases on social media to\nunlock pending cash backs!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.unfilled,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FiltersAndList extends StatefulWidget {
  @override
  State<_FiltersAndList> createState() => _FiltersAndListState();
}

class _FiltersAndListState extends State<_FiltersAndList> {
  String _selectedChip = 'All time';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _chip('All time'),
                  const SizedBox(width: 8),
                  _chip('This week'),
                  const SizedBox(width: 8),
                  _chip('Last week'),
                  const Spacer(),
                  _chip('Filter', leading: Icons.tune_rounded, outlined: true),
                ],
              ),
              const SizedBox(height: 12),
              // Yellow progress dash
              Stack(
                children: [
                  // Background (unfilled part)
                  Container(
                    height: 8,
                    width: 400,
                    decoration: BoxDecoration(
                      color: const Color(0xffE4E4E4),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  // Filled (colored part)
                  Container(
                    height: 8,
                    width:
                        200, // 👈 half of total width (adjust dynamically if needed)
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recent transactions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    '0 transactions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xff909090),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0xff909090),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, {IconData? leading, bool outlined = false}) {
    final bool isSelected = _selectedChip == text;

    // Filter chip has unique styling
    final bool isFilterChip = text == 'Filter';

    return GestureDetector(
      onTap: isFilterChip
          ? () {
              // Open filter dialog or bottom sheet if needed
            }
          : () {
              setState(() {
                _selectedChip = text;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isFilterChip
              ? Colors.white
              : (isSelected ? AppColors.primary : const Color(0xffE4E4E4)),
          border: outlined || isFilterChip
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(
                leading,
                size: 16,
                color: isFilterChip
                    ? AppColors.primary
                    : (isSelected ? Colors.white : AppColors.black),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isFilterChip
                    ? AppColors.primary
                    : (isSelected ? Colors.white : AppColors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
