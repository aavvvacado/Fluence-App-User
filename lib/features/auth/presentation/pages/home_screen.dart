import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluence/features/auth/presentation/pages/start_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/merchant.dart';
import '../../../../core/models/merchant_card.dart';
import '../../../../core/models/profile_completion_response.dart';
import '../../../../core/models/promo_item.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/shared_preferences_service.dart';
import '../../../../core/widgets/CashbackSwiper.dart';
// Removed DiscountPromoSection globally as per requirement
import '../../../../core/widgets/searchable_discover_merchants_section.dart';
import '../../../../core/widgets/fluence_card.dart';
import '../../../../core/widgets/home_bottom_nav_bar.dart';
import '../../../../core/widgets/home_header.dart';
import '../../../../core/widgets/top_merchants_section.dart';
import '../../../guest/presentation/guest_guard.dart';
import '../../../../core/bloc/notification_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  bool _shownProfileCompletionBottomSheet = false;

  List<Merchant> _topMerchants = [];
  bool _isLoadingMerchants = true;
  String? _merchantsError;
  bool _isMerchantsExpanded = false;

  int? _totalPoints;
  bool _loadingPoints = true;
  String? _pointsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showProfileCompletionIfNeeded(),
    );
    if (!SharedPreferencesService.isGuest()) {
      _fetchActiveMerchants();
      _fetchTotalPoints();
      // Load unread notification count
      context.read<NotificationBloc>().add(const LoadUnreadCount());
    } else {
      _topMerchants = const [
        Merchant(
          name: 'The Coffee Club',
          category: 'Cafe',
          icon: Icons.local_cafe,
          color: Colors.green,
        ),
        Merchant(
          name: 'Sephora',
          category: 'Beauty',
          icon: Icons.face,
          color: Colors.pink,
        ),
        Merchant(
          name: 'Amazon',
          category: 'E-Commerce',
          icon: Icons.shopping_bag,
          color: Colors.orange,
        ),
        Merchant(
          name: 'GymX',
          category: 'Fitness',
          icon: Icons.fitness_center,
          color: Colors.blue,
        ),
        Merchant(
          name: 'Burger Hub',
          category: 'Food',
          icon: Icons.fastfood,
          color: Colors.red,
        ),
      ];
      _isLoadingMerchants = false;
      _totalPoints = 0;
      _loadingPoints = false;
    }
  }

  Future<void> _showProfileCompletionIfNeeded() async {
    final needsProfileCompletion =
        SharedPreferencesService.getNeedsProfileCompletionFlag();
    if (needsProfileCompletion == true && !_shownProfileCompletionBottomSheet) {
      _shownProfileCompletionBottomSheet = true;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: ProfileCompletionForm(
              onCompleted: () async {
                _shownProfileCompletionBottomSheet = true;
                if (!SharedPreferencesService.isGuest()) {
                  await _fetchActiveMerchants();
                  await _fetchTotalPoints();
                }
                if (mounted) setState(() {});
              },
            ),
          ),
        ),
      );
    }
  }

  Future<void> _fetchActiveMerchants() async {
    setState(() {
      _isLoadingMerchants = true;
      _merchantsError = null;
    });
    try {
      final data = await ApiService.fetchActiveMerchants();
      // Map API data to Merchant model
      List<Merchant> merchants = (data as List).map((item) {
        // Defensive: Provide fallback if some fields missing
        String name = item['name'] ?? 'Unknown';
        String category = item['category'] ?? 'Misc';
        // Choose icon/color by category, fallback if not present
        IconData icon;
        Color color;
        switch (category.toLowerCase()) {
          case 'cafe':
            icon = Icons.local_cafe;
            color = Colors.green;
            break;
          case 'beauty':
            icon = Icons.face;
            color = Colors.pink;
            break;
          case 'e-commerce':
            icon = Icons.shopping_bag;
            color = Colors.orange;
            break;
          default:
            icon = Icons.store;
            color = Colors.blueGrey;
        }
        return Merchant(
          name: name,
          category: category,
          icon: icon,
          color: color,
        );
      }).toList();
      setState(() {
        _topMerchants = merchants;
        _isLoadingMerchants = false;
      });
    } catch (e) {
      setState(() {
        _merchantsError = 'Failed to load merchants.';
        _isLoadingMerchants = false;
        _topMerchants = [];
      });
    }
  }

  Future<void> _fetchTotalPoints() async {
    setState(() {
      _loadingPoints = true;
      _pointsError = null;
    });
    try {
      final result = await ApiService.fetchTotalPointsEarned();
      setState(() {
        _totalPoints = result;
        _loadingPoints = false;
      });
    } catch (e) {
      setState(() {
        _pointsError = 'Failed to load points.';
        _loadingPoints = false;
      });
    }
  }

  void _onNotificationTap(BuildContext context) {
    if (SharedPreferencesService.isGuest()) {
      showSignInRequiredSheet(context);
      return;
    }
    
    // Navigate to full-screen notification list
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationListScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  // Mock data - will be replaced with API calls
  final List<MerchantCard> _discoverMerchants = [
    const MerchantCard(category: 'Shoes', imagePath: 'assets/images/1.png'),
    const MerchantCard(category: 'Apparel', imagePath: 'assets/images/2.png'),
    const MerchantCard(category: 'Food', imagePath: 'assets/images/2.png'),
  ];

  final List<PromoItem> _promoItems = [
    const PromoItem(
      name: 'PR Parcels',
      currentPrice: '\$125',
      originalPrice: '\$169',
      imagePath: 'assets/images/3.png',
    ),
    const PromoItem(
      name: 'Hampers',
      currentPrice: '€8k',
      originalPrice: '€10.00',
      imagePath: 'assets/images/4.png',
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
    final userName = SharedPreferencesService.isGuest()
        ? 'Guest'
        : SharedPreferencesService.getUserName() ?? 'Romina';
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (!SharedPreferencesService.isGuest()) {
              await _fetchActiveMerchants();
              await _fetchTotalPoints();
            }
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
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
                        onNotificationTap: () => _onNotificationTap(context),
                      ),
                    ),
                    // Fluence Card positioned on the image
                    Positioned(
                      top: 120,
                      left: 24,
                      right: 24,
                      child: SharedPreferencesService.isGuest()
                          ? FluenceCard(
                              points: 0,
                              backgroundImagePath: null,
                              message:
                                  'to check your fluence score just sign in',
                              onTap: () => showSignInRequiredSheet(context),
                            )
                          : (_loadingPoints
                                ? const SizedBox(
                                    height: 140,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : FluenceCard(
                                    points: _totalPoints ?? 0,
                                    backgroundImagePath: null,
                                  )),
                    ),

                    // Cashback Swiper positioned on the image
                  ],
                ),

                const SizedBox(height: 16),
                const CashbackSwiper(),
                // Top Merchants Section
                if (_isLoadingMerchants) ...[
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ] else if (_merchantsError != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        _merchantsError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ] else ...[
                  TopMerchantsSection(
                    merchants: _topMerchants,
                    isExpanded: _isMerchantsExpanded,
                    onViewAll: () {
                      setState(
                        () => _isMerchantsExpanded = !_isMerchantsExpanded,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                // Discover Merchants Section with Search
                SearchableDiscoverMerchantsSection(
                  merchants: _discoverMerchants,
                  categories: _categories,
                  onMerchantTap: () {
                    // Handle merchant tap - can add navigation or other logic here
                    print('Merchant tapped');
                  },
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 120), // Space for bottom nav bar
              ],
            ),
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
                  if (isGuestUser()) {
                    _showSignupBottomSheet(context);
                  } else {
                    context.push('/payment/scan');
                  }
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

  void _showSignupBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Create an account to continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign up to scan and pay or view your transactions.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(StartScreen.path);
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
        );
      },
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
  void initState() {
    super.initState();
    // Prefill from saved or temp signup details
    _emailController.text =
        SharedPreferencesService.getUserEmail() ??
        SharedPreferencesService.getTempSignupEmail() ??
        '';
    _phoneController.text =
        SharedPreferencesService.getProfilePhone() ??
        SharedPreferencesService.getTempSignupPhone() ??
        '';
    _dobController.text = SharedPreferencesService.getTempSignupDob() ?? '';
  }

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
      setState(() {
        _errorMessage = 'Please fill all fields.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = SharedPreferencesService.getAuthToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'No user token found';
        _isLoading = false;
      });
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
      if (apiResp['user'] != null) {
        final profile = ProfileCompletionResponse.fromJson(apiResp);
        await SharedPreferencesService.saveFullUserProfile(
          id: profile.user.id,
          name: profile.user.name,
          email: profile.user.email,
          phone: profile.user.phone,
        );
        // Save refreshed auth token if provided by API
        final newToken = apiResp['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await SharedPreferencesService.saveToken(newToken);
        }
        // Turn off the flag so sheet won't show again
        await SharedPreferencesService.setNeedsProfileCompletionFlag(false);
        setState(() {
          _isLoading = false;
        });
        // Notify parent first so UI can refresh
        widget.onCompleted();
        // Close the bottom sheet
        if (context.mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = (apiResp['message'] ?? 'Profile completion failed!')
              .toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
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
          const Text(
            'Complete Your Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.primary,
              fontFamily: 'Poppins',
            ),
          ),
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
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.cake),
              border: OutlineInputBorder(),
              hintText: 'YYYY-MM-DD',
            ),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 18, now.month, now.day),
                firstDate: DateTime(1900),
                lastDate: now,
              );
              if (picked != null) {
                final yyyy = picked.year.toString().padLeft(4, '0');
                final mm = picked.month.toString().padLeft(2, '0');
                final dd = picked.day.toString().padLeft(2, '0');
                final formatted = '$yyyy-$mm-$dd';
                setState(() => _dobController.text = formatted);
                SharedPreferencesService.saveTempSignupDob(formatted);
              }
            },
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    // Only load notifications if we don't have any loaded yet
    final currentState = context.read<NotificationBloc>().state;
    if (currentState is! NotificationLoaded) {
      context.read<NotificationBloc>().add(const LoadNotifications());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.black,
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () async {
                    final shouldMarkAll = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Mark All as Read',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to mark all notifications as read?',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Mark All Read',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldMarkAll == true) {
                      context.read<NotificationBloc>().add(const MarkAllAsRead());
                    }
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is AllNotificationsMarkedAsRead) {
            // Show a snackbar for mark all as read
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('All notifications marked as read'),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<NotificationBloc>().add(const LoadNotifications());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We\'ll notify you when something exciting happens!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const RefreshNotifications());
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Delete Notification',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this notification?',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      context.read<NotificationBloc>().add(
                        DeleteNotification(notification.id),
                      );
                    },
                    child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (!notification.isRead) {
                            context.read<NotificationBloc>().add(
                              MarkAsRead(notification.id),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Notification icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: notification.isRead 
                                      ? Colors.grey[200] 
                                      : AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getNotificationIcon(notification.type),
                                  color: notification.isRead 
                                      ? Colors.grey[600] 
                                      : AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Notification content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notification.title,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: notification.isRead 
                                                  ? FontWeight.w500 
                                                  : FontWeight.bold,
                                              color: notification.isRead 
                                                  ? Colors.grey[600] 
                                                  : AppColors.black,
                                            ),
                                          ),
                                        ),
                                        if (!notification.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      notification.message,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.grey,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(notification.createdAt),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Action buttons
                              Column(
                                children: [
                                  if (!notification.isRead)
                                    IconButton(
                                      onPressed: () {
                                        context.read<NotificationBloc>().add(
                                          MarkAsRead(notification.id),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  );
                },
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cashback_earned':
        return Icons.attach_money;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.settings;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'merchant':
        return Icons.store;
      case 'reward':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  void _showSignupBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Create an account to continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign up to scan and pay or view your transactions.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(StartScreen.path);
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
