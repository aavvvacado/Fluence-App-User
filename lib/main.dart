import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/utils/custom_page_transition.dart';
import 'di/injection_container.dart' as di;
import 'di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/create_account_screen.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/presentation/pages/wallet_screen.dart';
import 'features/auth/presentation/pages/profile_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/new_password_screen.dart';
import 'features/auth/presentation/pages/otp_screen.dart';
import 'features/auth/presentation/pages/password_pin_screen.dart';
import 'features/auth/presentation/pages/ready_screen.dart';
import 'features/auth/presentation/pages/recovery_options_screen.dart';
import 'features/auth/presentation/pages/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize Dependency Injection
  runApp(const FluenceApp());
}

// Dummy Home Screen for final navigation

final _router = GoRouter(
  initialLocation: StartScreen.path,
  routes: [
    GoRoute(
      path: StartScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const StartScreen(),
      ),
    ),
    GoRoute(
      path: CreateAccountScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const CreateAccountScreen(),
      ),
    ),
    GoRoute(
      path: LoginScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: PasswordPinScreen.path,
      pageBuilder: (context, state) {
        final Map<String, dynamic> extra =
            state.extra as Map<String, dynamic>? ?? {};
        return buildPageWithSlideTransition(
          context: context,
          state: state,
          child: PasswordPinScreen(
            email: extra['email'] ?? 'unknown',
            name: extra['name'] ?? 'User',
          ),
        );
      },
    ),
    GoRoute(
      path: RecoveryOptionsScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const RecoveryOptionsScreen(),
      ),
    ),
    GoRoute(
      path: OtpScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: OtpScreen(method: state.extra as String? ?? 'sms'),
      ),
    ),
    GoRoute(
      path: NewPasswordScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const NewPasswordScreen(),
      ),
    ),
    GoRoute(
      path: ReadyScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const ReadyScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    ),
    GoRoute(
      path: WalletScreen.path,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WalletScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    ),
    GoRoute(
      path: ProfileScreen.path,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    ),
  ],
);

class FluenceApp extends StatelessWidget {
  const FluenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the AuthBloc at the top of the widget tree
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => sl<AuthBloc>())],
      child: MaterialApp.router(
        title: 'Fluence Pay',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber)
              .copyWith(
                primary: AppColors.primary,
                secondary: AppColors.primaryDark,
              ),
          scaffoldBackgroundColor: AppColors.white,
          fontFamily:
              'Montserrat', // Assuming a modern font like Montserrat or Inter
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
