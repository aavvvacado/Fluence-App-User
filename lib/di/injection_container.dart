import 'package:get_it/get_it.dart';

import '../core/utils/shared_preferences_service.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user.dart';
import '../features/auth/domain/usecases/login.dart';
import '../features/auth/domain/usecases/logout.dart';
import '../features/auth/domain/usecases/sign_up.dart';
import '../features/auth/domain/usecases/complete_profile.dart';
import '../features/auth/domain/usecases/update_account_status.dart';
import '../features/auth/domain/usecases/reset_password_with_email.dart';
import '../features/auth/domain/usecases/send_phone_otp.dart';
import '../features/auth/domain/usecases/verify_phone_otp.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../core/services/notification_service.dart';
import '../core/bloc/notification_bloc.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // Initialize shared preferences
  await SharedPreferencesService.init();

  // BLoC
  sl.registerFactory(() => AuthBloc(
    login: sl(),
    signUp: sl(),
    logout: sl(),
    getCurrentUser: sl(),
    resetPasswordWithEmail: sl(),
    sendPhoneOtp: sl(),
    verifyPhoneOtp: sl(),
  ));

  sl.registerFactory(() => NotificationBloc());

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => CompleteProfile(sl()));
  sl.registerLazySingleton(() => UpdateAccountStatus(sl()));
  sl.registerLazySingleton(() => ResetPasswordWithEmail(sl()));
  sl.registerLazySingleton(() => SendPhoneOtp(sl()));
  sl.registerLazySingleton(() => VerifyPhoneOtp(sl()));

  // Repository (DIP: Abstraction is registered, Implementation is provided)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Data sources
  // The Firebase data source implementation is registered here.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Services
  sl.registerLazySingleton(() => NotificationService());
}
