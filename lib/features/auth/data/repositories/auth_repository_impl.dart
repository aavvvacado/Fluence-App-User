import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

// SOLID: AuthRepositoryImpl adheres to the AuthRepository interface (DIP)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  // --- Login Implementation ---
  @override
  Future<Either<Failure, UserEntity>> signIn(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signIn(email, password);
      return Right(user);
    } on ServerException catch (e) {
      // Convert Data layer exception into a Domain layer failure
      return Left(ServerFailure(message: e.message));
    } on Exception {
      // Catch any other unexpected exceptions
      return const Left(
        ServerFailure(message: 'Unknown error occurred during sign in.'),
      );
    }
  }

  // --- Sign Up Implementation ---
  @override
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String phone,
  ) async {
    try {
      final user = await remoteDataSource.signUp(email, password, phone);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(
        ServerFailure(message: 'Unknown error occurred during sign up.'),
      );
    }
  }

  // --- Password Recovery Implementation ---
  @override
  Future<Either<Failure, void>> resetPassword(String method) async {
    try {
      await remoteDataSource.resetPassword(method);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // --- OTP Verification Implementation ---
  @override
  Future<Either<Failure, void>> verifyOtp(String otp) async {
    try {
      await remoteDataSource.verifyOtp(otp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // --- Set New Password Implementation ---
  @override
  Future<Either<Failure, void>> setNewPassword(String newPassword) async {
    try {
      await remoteDataSource.setNewPassword(newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
