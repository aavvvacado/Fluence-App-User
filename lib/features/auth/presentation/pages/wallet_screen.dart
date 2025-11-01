import 'package:fluence/features/auth/presentation/pages/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/points_stats_bloc.dart';
import '../../../../core/bloc/points_transactions_bloc.dart';
import '../../../../core/bloc/wallet_balance_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/points_transaction.dart';
import '../../../../core/widgets/home_bottom_nav_bar.dart';
import '../../../../core/widgets/wallet_header.dart';
import '../../../guest/presentation/guest_guard.dart';

class WalletScreen extends StatefulWidget {
  static const String path = '/wallet';

  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedIndex = 2; // Wallet tab

  @override
  void initState() {
    super.initState();
    if (!isGuestUser()) {
      // Load wallet balance using BLoC
      context.read<WalletBalanceBloc>().add(const LoadWalletBalance());
      // Load points stats using BLoC
      context.read<PointsStatsBloc>().add(const LoadPointsStats());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double headerHeight = (screen.height * 0.24).clamp(200.0, 320.0);
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
              totalLabel:
                  ' Great job!\n Your 250 points can unlock 150\n cashback on exciting offers',
            ),
          ),
          // Scrollable content area - starts below header
          Positioned(
            top: panelTopPosition,
            left: 0,
            right: 0,
            bottom: 0,
            child: RefreshIndicator(
              onRefresh: () async {
                if (!isGuestUser()) {
                  // Refresh wallet balance using BLoC
                  context.read<WalletBalanceBloc>().add(
                    const RefreshWalletBalance(),
                  );
                  // Refresh points stats using BLoC
                  context.read<PointsStatsBloc>().add(
                    const RefreshPointsStats(),
                  );
                  // Refresh points transactions
                  context.read<PointsTransactionsBloc>().add(
                    const RefreshPointsTransactions(),
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: const _StatsPanel(),
                    ),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _FiltersAndList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
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

class _WalletBalanceCard extends StatelessWidget {
  final double total;
  final String currency;

  const _WalletBalanceCard({required this.total, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$currency ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================== Widgets ===================

class _StatsPanel extends StatefulWidget {
  const _StatsPanel();

  @override
  State<_StatsPanel> createState() => _StatsPanelState();
}

class _StatsPanelState extends State<_StatsPanel> {
  bool _isPointsVisible = false; // Initially hidden

  @override
  Widget build(BuildContext context) {
    final bool isGuest = isGuestUser();

    // Show guest-specific UI instead of zeros
    if (isGuest) {
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
              imagePath: 'assets/images/total_points.png',
              title: 'TOTAL POINTS',
              trailing: GestureDetector(
                onTap: () => showSignInRequiredSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Sign in to view',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _rowItem(
              context,
              imagePath: 'assets/images/pending.png',
              title: 'PENDING',
              trailing: GestureDetector(
                onTap: () => showSignInRequiredSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Sign in to view',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _rowItem(
              context,
              imagePath: 'assets/images/money.png',
              title: 'TRANSACTIONS',
              trailing: GestureDetector(
                onTap: () => showSignInRequiredSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Sign in to view',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Sign in to unlock full features and view your stats!',
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

    // Authenticated user UI - shows actual data
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
          // AVAILABLE POINTS - Using PointsStatsBloc with eye toggle
          BlocBuilder<PointsStatsBloc, PointsStatsState>(
            builder: (context, state) {
              if (state.loading) {
                return _rowItem(
                  context,
                  imagePath: 'assets/images/total_points.png',
                  title: 'TOTAL POINTS',
                  trailing: SizedBox(
                    height: 16,
                    width: 32,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final points = state.stats?.currentBalance ?? 0;

              return _rowItem(
                context,
                imagePath: 'assets/images/total_points.png',
                title: 'TOTAL POINTS',
                trailing: _TotalPointsWithToggle(
                  points: points,
                  isVisible: _isPointsVisible,
                  onToggle: () {
                    setState(() {
                      _isPointsVisible = !_isPointsVisible;
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // PENDING - Using WalletBalanceBloc
          BlocBuilder<WalletBalanceBloc, WalletBalanceState>(
            builder: (context, state) {
              return _rowItem(
                context,
                imagePath: 'assets/images/pending.png',
                title: 'PENDING',
                trailing: _pill(
                  '${state.balance?.pendingBalance.toStringAsFixed(2) ?? '0.00'}',
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // TRANSACTIONS - Using PointsTransactionsBloc for count
          BlocBuilder<PointsTransactionsBloc, PointsTransactionsState>(
            builder: (context, state) {
              return _rowItem(
                context,
                imagePath: 'assets/images/money.png',
                title: 'TRANSACTIONS',
                trailing: state.loading
                    ? SizedBox(
                        height: 16,
                        width: 32,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _pill('${state.transactions.length}'),
              );
            },
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
    required String imagePath, // <-- instead of IconData
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
            child: Center(
              child: Image.asset(
                imagePath,
                width: 22,
                height: 22,
                // Removed color tint to show original image colors
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image, color: AppColors.primary, size: 22);
                },
              ),
            ),
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
          GestureDetector(
            onTap: () {
              if (isGuestUser()) {
                showSignInRequiredSheet(context);
              }
            },
            child: trailing,
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      width: 80, // Fixed width to match other boxes
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
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

// Widget for total points with eye toggle button
class _TotalPointsWithToggle extends StatelessWidget {
  final int points;
  final bool isVisible;
  final VoidCallback onToggle;

  const _TotalPointsWithToggle({
    required this.points,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 80, // Fixed width to match other boxes
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary, // Golden/yellow background
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Points value (hidden or visible)
            Text(
              isVisible ? '$points' : '•••',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            // Eye icon
            Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersAndList extends StatefulWidget {
  const _FiltersAndList({super.key});

  @override
  State<_FiltersAndList> createState() => _FiltersAndListState();
}

class _FiltersAndListState extends State<_FiltersAndList> {
  String _selectedChip = 'All time';
  DateTime? _fromDate;
  DateTime? _toDate;
  final List<Map<String, dynamic>> _allTransactions = [];

  // 🧾 Hardcoded sample transactions for logged-in users only

  // Check if user is guest using SharedPreferencesService
  bool get _isGuest => isGuestUser();
  @override
  void initState() {
    super.initState();
    if (!_isGuest) {
      context.read<PointsTransactionsBloc>().add(
        const LoadPointsTransactions(page: 1, limit: 50),
      );
    }
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> input) {
    if (_isGuest) return [];
    List<Map<String, dynamic>> list = List.of(input);
    final now = DateTime.now();
    if (_selectedChip == 'This week') {
      list = list.where((tx) {
        final diff = now.difference(tx['date']).inDays;
        return diff <= 7;
      }).toList();
    } else if (_selectedChip == 'Last week') {
      list = list.where((tx) {
        final diff = now.difference(tx['date']).inDays;
        return diff > 7 && diff <= 14;
      }).toList();
    }
    if (_fromDate != null && _toDate != null) {
      final DateTime from = DateTime(
        _fromDate!.year,
        _fromDate!.month,
        _fromDate!.day,
      );
      final DateTime to = DateTime(
        _toDate!.year,
        _toDate!.month,
        _toDate!.day,
        23,
        59,
        59,
      );
      list = list.where((tx) {
        final DateTime? date = tx['date'] as DateTime?;
        if (date == null) return false;
        return !date.isBefore(from) && !date.isAfter(to);
      }).toList();
    }
    return list;
  }

  // Transactions will be fetched from API in the future. No mock data.

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_isGuest) return []; // 🚫 No transactions for guest

    List<Map<String, dynamic>> list = List.of(_allTransactions);
    final now = DateTime.now();

    // Apply chip-based filtering first
    if (_selectedChip == 'This week') {
      list = list.where((tx) {
        final diff = now.difference(tx['date']).inDays;
        return diff <= 7;
      }).toList();
    } else if (_selectedChip == 'Last week') {
      list = list.where((tx) {
        final diff = now.difference(tx['date']).inDays;
        return diff > 7 && diff <= 14;
      }).toList();
    }
    // 'All time' shows all transactions

    // Apply custom date range filter if both dates are selected
    if (_fromDate != null && _toDate != null) {
      final DateTime from = DateTime(
        _fromDate!.year,
        _fromDate!.month,
        _fromDate!.day,
      );
      final DateTime to = DateTime(
        _toDate!.year,
        _toDate!.month,
        _toDate!.day,
        23,
        59,
        59,
      );
      list = list.where((tx) {
        final DateTime? date = tx['date'] as DateTime?;
        if (date == null) return false;
        return !date.isBefore(from) && !date.isAfter(to);
      }).toList();
    }

    return list;
  }

  String _formatPrettyDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'pm' : 'am';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$day $month, $hour:$minute $period';
  }

  String _formatTrailingValue(Map<String, dynamic> tx) {
    final int? points = tx['points'] as int?;
    if (points != null) {
      return '$points points';
    }
    final String currency = (tx['currency'] ?? '') as String;
    final double amount = (tx['amount'] ?? 0).toDouble();
    final bool isEarned = tx['type'] == 'Earned';
    return '${isEarned ? '+' : '-'}$currency ${amount.toStringAsFixed(2)}';
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

  Future<void> _onFilterTap() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: (_fromDate != null && _toDate != null)
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : DateTimeRange(start: lastMonth, end: now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final txState = context.watch<PointsTransactionsBloc>().state;
    // Map API model -> existing UI shape
    final mapped = txState.transactions
        .map(
          (PointsTransaction t) => {
            'title': t.description.isNotEmpty ? t.description : 'Points',
            'points': t.points,
            'date': t.createdAt,
            'status': t.status,
            'source': t.source,
          },
        )
        .toList();
    final filteredList = _applyFilters(mapped);
    final size = MediaQuery.of(context).size;

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
              // 🔸 Filter Chips Row (hide for guest)
              if (!_isGuest)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _chip('All time'),
                      const SizedBox(width: 8),
                      _chip('This week'),
                      const SizedBox(width: 8),
                      _chip('Last week'),
                      const SizedBox(width: 8),
                      _chip(
                        'Filter',
                        leading: Icons.tune_rounded,
                        outlined: true,
                        onTap: _onFilterTap,
                      ),
                    ],
                  ),
                ),

              if (!_isGuest) const SizedBox(height: 12),

              // Show selected date range, if any
              if (_fromDate != null && _toDate != null) ...[
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF0F2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatDate(_fromDate!)} → ${_formatDate(_toDate!)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: _clearDateRange,
                      tooltip: 'Clear date range',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Dashed line with transaction count
              Row(children: [Expanded(child: _buildDashedLine())]),
              const SizedBox(height: 12),

              // Title with transaction count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent transactions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    '${filteredList.length} transactions',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 👤 Guest User Placeholder
              if (_isGuest)
                GestureDetector(
                  onTap: () => _showSignupBottomSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.06,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary.withOpacity(0.8),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sign in to see your transactions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Color(0xff707070),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // 💸 Logged-in user list
              else if (filteredList.isEmpty)
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
                        decoration: const BoxDecoration(
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
                )
              else
                Column(
                  children: filteredList.map((tx) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x143369FF), // 8% opacity primary
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/total_points.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx['title'],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrettyDate(tx['date'] as DateTime),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Color(0xff909090),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatTrailingValue(tx),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF909090),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(
    String text, {
    IconData? leading,
    bool outlined = false,
    VoidCallback? onTap,
  }) {
    final bool isSelected = _selectedChip == text;
    final bool isFilterChip = text == 'Filter';

    return GestureDetector(
      onTap:
          onTap ??
          (isFilterChip
              ? () {}
              : () {
                  setState(() {
                    _selectedChip = text;
                  });
                }),
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

  Widget _buildDashedLine() {
    return SizedBox(
      height: 6, // line thickness
      width: double.infinity,
      child: Row(
        children: [
          // 60% Primary color
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(30),
                ),
              ),
            ),
          ),
          // 40% Grey color
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
