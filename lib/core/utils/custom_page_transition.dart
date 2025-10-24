import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Smooth transition utility for lag-free screen changes
CustomTransitionPage<T> buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Use Slide Transition for a smooth push effect
      const begin = Offset(1.0, 0.0); // Starts from the right
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart; // A smooth, fast curve

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
