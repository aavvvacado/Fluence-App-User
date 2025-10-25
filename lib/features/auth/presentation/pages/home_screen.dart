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
import '../../../../core/utils/shared_preferences_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/profile_completion_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  bool _shownProfileCompletionBottomSheet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showProfileCompletionIfNeeded());
  }

  Future<void> _showProfileCompletionIfNeeded() async {
    final needsProfileCompletion = SharedPreferencesService.getNeedsProfileCompletionFlag();
    if (needsProfileCompletion == true && !_shownProfileCompletionBottomSheet) {
      _shownProfileCompletionBottomSheet = true;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(child: ProfileCompletionForm(onCompleted: () {
            setState(() {}); // Trigger UI update for new name
            Navigator.of(context).pop();
          })),
        ),
      );
    }
  }

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
    final userName = SharedPreferencesService.getUserName() ?? 'Romina';
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
                      userName: userName,
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

class ProfileCompletionForm extends StatefulWidget {
  final VoidCallback onCompleted;

  const ProfileCompletionForm({super.key, required this.onCompleted});

  @override
  State<ProfileCompletionForm> createState() => _ProfileCompletionFormState();
}

class _ProfileCompletionFormState extends State<ProfileCompletionForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty) {
      setState(() { _errorMessage = 'Please fill all fields.'; });
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final token = SharedPreferencesService.getAuthToken();
    if (token == null || token.isEmpty) {
      setState(() { _errorMessage = 'No user token found'; _isLoading = false; });
      return;
    }
    try {
      final apiResp = await ApiService.completeProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        email: _emailController.text.trim(),
        authToken: token,
      );
      if (apiResp['success'] == true) {
        final profile = ProfileCompletionResponse.fromJson(apiResp);
        await SharedPreferencesService.saveFullUserProfile(
          id: profile.user.id,
          name: profile.user.name,
          email: profile.user.email,
          phone: profile.user.phone,
        );
        await SharedPreferencesService.setNeedsProfileCompletionFlag(false);
        setState(() { _isLoading = false; });
        widget.onCompleted();
        if (context.mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = (apiResp['message'] ?? 'Profile completion failed!').toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() { _errorMessage = 'An error occurred. Please try again.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Complete Your Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primary,
                fontFamily: 'Poppins',
              )),
          const SizedBox(height: 18),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dobController,
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.cake),
              border: OutlineInputBorder(),
              hintText: 'YYYY-MM-DD',
            ),
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Poppins')),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
