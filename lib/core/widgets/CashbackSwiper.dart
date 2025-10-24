import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/widgets/cashback_earned_card.dart';

class CashbackSwiper extends StatefulWidget {
  const CashbackSwiper({super.key});

  @override
  State<CashbackSwiper> createState() => _CashbackSwiperState();
}

class _CashbackSwiperState extends State<CashbackSwiper> {
  final _controller = PageController();
  final _cards = [
    {'amount': 1230, 'currency': '\$'},
    {'amount': 8500, 'currency': '₹'},
    {'amount': 4420, 'currency': '€'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // 👈 circular active dot
            activeDotColor: const Color(0xffD4AF37),
            dotColor: const Color(0xffD9D9D9),
            dotHeight: 10,
            dotWidth: 10,
            radius: 10, // make sure this matches dot size to keep it circular
          ),
        ),
      ],
    );
  }
}
