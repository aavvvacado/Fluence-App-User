import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/services/api_service.dart';
import '../../core/utils/shared_preferences_service.dart';
import '../../core/widgets/cashback_earned_card.dart';
import '../../features/guest/presentation/guest_guard.dart';

class CashbackSwiper extends StatefulWidget {
  const CashbackSwiper({super.key});

  @override
  State<CashbackSwiper> createState() => _CashbackSwiperState();
}

class _CashbackSwiperState extends State<CashbackSwiper> {
  final _controller = PageController();
  List<Map<String, dynamic>> _cards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (SharedPreferencesService.isGuest()) {
      setState(() {
        _cards = [];
        _loading = false;
      });
    } else {
      _fetchCampaigns();
    }
  }

  Future<void> _fetchCampaigns() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.fetchCashbackCampaigns();
      print('[CashbackSwiper] Raw campaign data: $data'); // Debug log

      // API returns: { campaigns: [...], pagination: {...} }
      final campaignsList = data['campaigns'] as List? ?? [];

      // Map campaigns to card format
      List<Map<String, dynamic>> cards = campaignsList
          .where((d) => d['cashbackPercentage'] != null)
          .map((d) {
            // Extract campaign data
            final cashbackPct = d['cashbackPercentage'] as num? ?? 0;
            final name = d['name'] as String? ?? '';

            return {
              'amount': cashbackPct
                  .toInt(), // Use cashback percentage as amount
              'currency': '%', // Show as percentage
              'name': name, // Store campaign name
            };
          })
          .toList();

      print('[CashbackSwiper] Mapped cards: $cards'); // Debug log

      setState(() {
        _cards = cards;
        _loading = false;
      });
    } catch (e) {
      print('[CashbackSwiper] Error fetching campaigns: $e'); // Debug log
      setState(() {
        _error = 'Failed to load cashback campaigns';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(_error!, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (SharedPreferencesService.isGuest()) {
      // Always display three cards with guest message - using same design as API data
      final guestCards = [
        {'amount': 0, 'title': 'Total Points'},
        {'amount': 0, 'title': 'Number of Visits'},
        {'amount': 0, 'title': 'Referrals'},
      ];

      return Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _controller,
              itemCount: 3,
              itemBuilder: (context, index) {
                final card = guestCards[index];
                return GestureDetector(
                  onTap: () => showSignInRequiredSheet(context),
                  child: CashbackEarnedCard(
                    amount: card['amount'] as int,
                    title: card['title'] as String,
                    subtitle: 'Sign in to start earning',
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SmoothPageIndicator(
            controller: _controller,
            count: 3,
            effect: WormEffect(
              activeDotColor: const Color(0xffD4AF37),
              dotColor: const Color(0xffD9D9D9),
              dotHeight: 10,
              dotWidth: 10,
              radius: 10,
            ),
          ),
        ],
      );
    }

    if (_cards.isEmpty) {
      // Non-guest empty fallback: three cards with same design as guest mode
      final fallbackCards = [
        {'amount': 0, 'title': 'Total Points'},
        {'amount': 0, 'title': 'Number of Visits'},
        {'amount': 0, 'title': 'Referrals'},
      ];

      return Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _controller,
              itemCount: 3,
              itemBuilder: (context, index) {
                final card = fallbackCards[index];
                return CashbackEarnedCard(
                  amount: card['amount'] as int,
                  title: card['title'] as String,
                  subtitle: '',
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SmoothPageIndicator(
            controller: _controller,
            count: 3,
            effect: WormEffect(
              activeDotColor: const Color(0xffD4AF37),
              dotColor: const Color(0xffD9D9D9),
              dotHeight: 10,
              dotWidth: 10,
              radius: 10,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              return CashbackEarnedCard(
                amount: card['amount'] as int,
                currency: card['currency'] as String,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _controller,
          count: _cards.length,
          effect: WormEffect(
            activeDotColor: const Color(0xffD4AF37),
            dotColor: const Color(0xffD9D9D9),
            dotHeight: 10,
            dotWidth: 10,
            radius: 10,
          ),
        ),
      ],
    );
  }
}
