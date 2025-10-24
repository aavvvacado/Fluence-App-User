import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/merchant.dart';
import '../../../../core/models/merchant_card.dart';
import '../../../../core/models/promo_item.dart';
import '../../../../core/widgets/CashbackSwiper.dart';
import '../../../../core/widgets/discount_promo_section.dart';
import '../../../../core/widgets/discover_merchants_section.dart';
import '../../../../core/widgets/fluence_card.dart';
import '../../../../core/widgets/home_bottom_nav_bar.dart';
import '../../../../core/widgets/home_header.dart';
import '../../../../core/widgets/top_merchants_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  // Mock data - will be replaced with API calls
  final List<Merchant> _topMerchants = [
    const Merchant(
      name: 'The Coffee Club',
      category: 'Cafe',
      icon: Icons.local_cafe,
      color: Colors.green,
    ),
    const Merchant(
      name: 'Sephora',
      category: 'Beauty',
      icon: Icons.face,
      color: Colors.pink,
    ),
    const Merchant(
      name: 'Amazon',
      category: 'E-Commerce',
      icon: Icons.shopping_bag,
      color: Colors.orange,
    ),
  ];

  final List<MerchantCard> _discoverMerchants = [
    const MerchantCard(category: 'Shoes', imagePath: null),
    const MerchantCard(category: 'Apparel', imagePath: null),
    const MerchantCard(category: 'Food', imagePath: null),
  ];

  final List<PromoItem> _promoItems = [
    const PromoItem(
      name: 'PR Parcels',
      currentPrice: '\$125',
      originalPrice: '\$169',
      imagePath: null,
    ),
    const PromoItem(
      name: 'Hampers',
      currentPrice: '€8k',
      originalPrice: '€10.00',
      imagePath: null,
    ),
  ];

  final List<String> _categories = [
    'All',
    'Apparel',
    'Food & Beverages',
    'Fitness',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with background image and overlaid content
              Stack(
                children: [
                  // Background Image
                  Container(
                    height:
                        MediaQuery.of(context).size.height *
                        0.28, // Increased height to accommodate all content
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/android.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  // Header content
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: HomeHeader(
                      userName: 'Romina',
                      avatarPath: 'assets/images/artist-2 1.png',
                    ),
                  ),
                  // Fluence Card positioned on the image
                  Positioned(
                    top:
                        120, // Adjust this value to position the card correctly
                    left: 24,
                    right: 24,
                    child: FluenceCard(points: 7820, backgroundImagePath: null),
                  ),

                  // Cashback Swiper positioned on the image
                ],
              ),

              const SizedBox(height: 16),
              const CashbackSwiper(),
              // Top Merchants Section
              TopMerchantsSection(
                merchants: _topMerchants,
                onViewAll: () {
                  // Navigate to full merchants list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all merchants')),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Discover Merchants Section
              DiscoverMerchantsSection(
                merchants: _discoverMerchants,
                categories: _categories,
                onSearch: (query) {
                  // Handle search - TODO: Implement search functionality
                },
                onCategorySelected: (category) {
                  // Handle category selection - TODO: Implement category filtering
                },
              ),
              const SizedBox(height: 16),
              // Discount and Promo Section
              DiscountPromoSection(promoItems: _promoItems),
              const SizedBox(
                height: 120,
              ), // Space for bottom nav bar// Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor, // pure white to match body
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // soft divider shadow
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: HomeBottomNavBar(
            selectedIndex: _selectedNavIndex,
            onTap: (index) {
              setState(() => _selectedNavIndex = index);
              switch (index) {
                case 0:
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
                  context.go('/profile');
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
