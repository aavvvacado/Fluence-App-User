import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String phone,
  );
  Future<Either<Failure, void>> resetPassword(String method);
  Future<Either<Failure, void>> verifyOtp(String otp);
  Future<Either<Failure, void>> setNewPassword(String newPassword);
}
