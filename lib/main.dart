import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/app_colors.dart';
import 'core/utils/custom_page_transition.dart';
import 'core/utils/shared_preferences_service.dart';
import 'di/injection_container.dart' as di;
import 'di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/create_account_screen.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/new_password_screen.dart';
import 'features/auth/presentation/pages/otp_screen.dart';
import 'features/auth/presentation/pages/password_pin_screen.dart';
import 'features/auth/presentation/pages/profile_screen.dart';
import 'features/auth/presentation/pages/ready_screen.dart';
import 'features/auth/presentation/pages/recovery_options_screen.dart';
import 'features/auth/presentation/pages/email_recovery_screen.dart';
import 'features/auth/presentation/pages/phone_recovery_screen.dart';
import 'features/auth/presentation/pages/start_screen.dart';
import 'features/auth/presentation/pages/wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  print('[Main] Environment variables loaded');
  print('[Main] AUTH_SERVICE_URL: ${dotenv.env['AUTH_SERVICE_URL']}');
  print('[Main] FIREBASE_AUTH_ENDPOINT: ${dotenv.env['FIREBASE_AUTH_ENDPOINT']}');
  
  await Firebase.initializeApp();
  await di.init(); // Initialize Dependency Injection
  runApp(const FluenceApp());
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('[AuthWrapper] AuthBloc state: $state');
        if (state is AuthAuthenticated) {
          print('[AuthWrapper] Navigating to /home...');
          // User is authenticated, navigate to home
          context.go('/home');
        } else if (state is AuthUnauthenticated || state is AuthLogoutSuccess) {
          print('[AuthWrapper] Navigating to StartScreen...');
          // User is not authenticated, navigate to start screen
          context.go(StartScreen.path);
        } else if (state is AuthSignUpSuccess) {
          print('[AuthWrapper] Signup complete; forcing new login.');
          // User is not authenticated, navigate to start screen
          context.go('/login');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // Check if user is logged in from shared preferences
          if (SharedPreferencesService.isLoggedIn()) {
            // Trigger auth check to verify Firebase session
            context.read<AuthBloc>().add(const AuthCheckRequested());
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // Show start screen for unauthenticated users
          return const StartScreen();
        },
      ),
    );
  }
}

// Dummy Home Screen for final navigation

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const AuthWrapper(),
      ),
    ),
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
      path: EmailRecoveryScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const EmailRecoveryScreen(),
      ),
    ),
    GoRoute(
      path: PhoneRecoveryScreen.path,
      pageBuilder: (context, state) => buildPageWithSlideTransition(
        context: context,
        state: state,
        child: const PhoneRecoveryScreen(),
      ),
    ),
    GoRoute(
      path: OtpScreen.path,
      pageBuilder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>? ?? {};
        return buildPageWithSlideTransition(
          context: context,
          state: state,
          child: OtpScreen(
            method: extra['method'] ?? 'sms',
            phoneNumber: extra['phoneNumber'],
            verificationId: extra['verificationId'],
          ),
        );
      },
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    ),
    GoRoute(
      path: WalletScreen.path,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WalletScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    ),
    GoRoute(
      path: ProfileScreen.path,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
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
