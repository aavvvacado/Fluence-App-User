import 'package:get_it/get_it.dart';

import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login.dart';
import '../features/auth/domain/usecases/sign_up.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => AuthBloc(login: sl(), signUp: sl()));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  // Register other use cases (e.g., ResetPassword) here...

  // Repository (DIP: Abstraction is registered, Implementation is provided)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Data sources
  // The dummy data source implementation is registered here.
  // To switch to a real API, you only change the implementation class here.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
}
