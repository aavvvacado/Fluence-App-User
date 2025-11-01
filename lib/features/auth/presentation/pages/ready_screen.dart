import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/shared_preferences_service.dart';
import '../../../../core/widgets/custom_app_button.dart';

class ReadyScreen extends StatefulWidget {
  static const String path = '/ready';
  const ReadyScreen({super.key});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _messages = const [
    'Earn rewards every time you spend!',
    'Making every payment more rewarding with instant cashback and offers.',
    'No waiting, no hassle — just smooth rewards with Fluence Pay.',
    'The more you use Fluence Pay, the more you earn!',
  ];

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;
    // Responsive sizes
    final double bubble1W = (w * 1.1).clamp(280.0, 420.0);
    final double bubble1H = (bubble1W * 1.1).clamp(300.0, 460.0);
    final double bubble2W = (w * 1.05).clamp(260.0, 400.0);
    final double bubble2H = (bubble2W * 1.15).clamp(300.0, 460.0);
    final double cardWidth = (w * 0.88).clamp(280.0, 520.0);
    final double imageHeight = (cardWidth * 0.58).clamp(180.0, 320.0);
    final double cardPadding = (w * 0.07).clamp(20.0, 30.0);
    final double vGapLarge = (h * 0.04).clamp(16.0, 40.0);
    final double vGapSmall = (h * 0.02).clamp(10.0, 20.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Yellow bubble top left
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/bubble_ready1.svg',
              width: bubble1W,
              height: bubble1H,
            ),
          ),
          // Blue bubble bottom right
          Positioned(
            top: (h * 0.42).clamp(260.0, 420.0),
            left: (w * 0.18).clamp(40.0, 90.0),
            child: Transform.rotate(
              angle: -108 * (3.14159 / 180), // Convert degrees to radians
              child: Opacity(
                opacity: 1.0,
                child: SvgPicture.asset(
                  'assets/images/bubble_ready2.svg',
                  width: bubble2W,
                  height: bubble2H,
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: vGapSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: imageHeight + (cardPadding * 2) + 300,
                    width: cardWidth,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 4,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: vGapSmall),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                  child: Image.asset(
                                    'assets/images/ready.png',
                                    height: imageHeight,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(cardPadding),
                                  child: Column(
                                    children: [
                                      SizedBox(height: vGapSmall),
                                      Text(
                                        'Ready?',
                                        style: TextStyle(
                                          fontSize: (w * 0.07).clamp(
                                            22.0,
                                            28.0,
                                          ),
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      SizedBox(height: vGapSmall * 0.8),
                                      Text(
                                        _messages[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: (w * 0.045).clamp(
                                            14.0,
                                            17.0,
                                          ),
                                          fontFamily: "Poppins",
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      SizedBox(height: vGapLarge),
                                      CustomAppButton(
                                        text: index < 3
                                            ? 'Skip'
                                            : "Let's Start",
                                        onPressed: () async {
                                          if (index < 3) {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          } else {
                                            await SharedPreferencesService.clearGuestSession();
                                            if (!mounted) return;
                                            context.go('/home');
                                          }
                                        },
                                        textStyle: const TextStyle(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔹 Dots moved outside the card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(_currentPage == 0),
                      const SizedBox(width: 8),
                      _buildDot(_currentPage == 1),
                      const SizedBox(width: 8),
                      _buildDot(_currentPage == 2),
                      const SizedBox(width: 8),
                      _buildDot(_currentPage == 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : Color(0xffC7D6FB),
      ),
    );
  }
}
