import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
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
  double? _walletTotalBalance;
  String? _walletCurrency;
  bool _loadingWallet = true;
  String? _walletError;

  @override
  void initState() {
    super.initState();
    if (!isGuestUser()) {
      _fetchWalletBalance();
    } else {
      _loadingWallet = false;
      _walletTotalBalance = 0.0;
      _walletCurrency = 'AED';
    }
  }

  Future<void> _fetchWalletBalance() async {
    setState(() {
      _loadingWallet = true;
      _walletError = null;
    });
    try {
      final data = await ApiService.fetchWalletBalance();
      setState(() {
        _walletTotalBalance = (data['totalBalance'] as num?)?.toDouble() ?? 0.0;
        _walletCurrency = data['currency'] as String? ?? '';
        _loadingWallet = false;
      });
    } catch (e) {
      setState(() {
        _walletError = 'Failed to load wallet balance.';
        _loadingWallet = false;
        _walletTotalBalance = 0.0;
        _walletCurrency = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.sizeOf(context).height * 0.24;
    final double panelTopPosition = headerHeight - 60;

    final String headerAmount = (isGuestUser())
        ? 'AED 0.00'
        : '${_walletCurrency ?? ''} ${(_walletTotalBalance ?? 0.0).toStringAsFixed(2)}';

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
              totalAmount: headerAmount,
              totalLabel: 'TOTAL CASHBACK EARNED',
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
                  await _fetchWalletBalance();
                }
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _StatsPanel(
                        totalBalance: _walletTotalBalance,
                        currency: _walletCurrency,
                        loading: _loadingWallet,
                      ),
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

class _StatsPanel extends StatelessWidget {
  final double? totalBalance;
  final String? currency;
  final bool loading;
  const _StatsPanel({this.totalBalance, this.currency, this.loading = false});

  bool get _isGuest => isGuestUser();

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
            trailing: loading
                ? SizedBox(
                    height: 16,
                    width: 32,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _pill(
                    '${currency ?? ''} ${_isGuest ? '0.00' : (totalBalance?.toStringAsFixed(2) ?? '0.00')}',
                  ),
          ),
          const SizedBox(height: 12),
          _rowItem(
            context,
            icon: Icons.timelapse_rounded,
            title: 'PENDING',
            trailing: _pill('${currency ?? ''} 0.00'),
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
    // Gate taps on the row if guest
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
  const _FiltersAndList({super.key});

  @override
  State<_FiltersAndList> createState() => _FiltersAndListState();
}

class _FiltersAndListState extends State<_FiltersAndList> {
  String _selectedChip = 'All time';

  // 🧾 Hardcoded sample transactions for logged-in users only
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 1,
      'title': 'Zara Purchase',
      'amount': 150.75,
      'currency': 'AED',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'Earned',
    },
    {
      'id': 2,
      'title': 'Starbucks Coffee',
      'amount': 45.00,
      'currency': 'AED',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'type': 'Spent',
    },
  ];

  // 🧠 Replace this with your actual auth check later
  bool get _isGuest => true; // ← Change to your real guest check logic

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_isGuest) return []; // 🚫 No transactions for guest
    final now = DateTime.now();

    if (_selectedChip == 'This week') {
      return _transactions.where((tx) {
        final diff = now.difference(tx['date']).inDays;
        return diff <= 7;
      }).toList();
    } else if (_selectedChip == 'Last week') {
      return _transactions.where((tx) {
        final diff = now.difference(tx['date']).inDays;
        return diff > 7 && diff <= 14;
      }).toList();
    } else {
      return _transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredTransactions;
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
                Row(
                  children: [
                    _chip('All time'),
                    const SizedBox(width: 8),
                    _chip('This week'),
                    const SizedBox(width: 8),
                    _chip('Last week'),
                    const Spacer(),
                    _chip(
                      'Filter',
                      leading: Icons.tune_rounded,
                      outlined: true,
                    ),
                  ],
                ),

              if (!_isGuest) const SizedBox(height: 12),

              // Title
              const Text(
                'Recent transactions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),

              // 👤 Guest User Placeholder
              if (_isGuest)
                Container(
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
                        color: const Color(0xffF8F8F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tx['type'] == 'Earned'
                                  ? AppColors.primary
                                  : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.attach_money_rounded,
                              color: Colors.white,
                              size: 24,
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
                                  '${tx['date'].day}/${tx['date'].month}/${tx['date'].year}',
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
                            '${tx['type'] == 'Earned' ? '+' : '-'}${tx['currency']} ${tx['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: tx['type'] == 'Earned'
                                  ? AppColors.primary
                                  : Colors.redAccent,
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

  Widget _chip(String text, {IconData? leading, bool outlined = false}) {
    final bool isSelected = _selectedChip == text;
    final bool isFilterChip = text == 'Filter';

    return GestureDetector(
      onTap: isFilterChip
          ? () {}
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
