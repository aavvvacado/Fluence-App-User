import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/profile_completion_response.dart';
import '../../../../core/models/account_status_response.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String phone,
  );
  Future<Either<Failure, void>> resetPasswordWithEmail(String email);
  Future<Either<Failure, void>> sendPhoneOtp(String phoneNumber);
  Future<Either<Failure, void>> verifyPhoneOtp(String verificationId, String otp);
  Future<Either<Failure, void>> verifyOtp(String otp);
  Future<Either<Failure, void>> setNewPassword(String newPassword);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, String?>> getAuthToken();
  Future<Either<Failure, ProfileCompletionResponse>> completeProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
    required String email,
  });
  Future<Either<Failure, AccountStatusResponse>> updateAccountStatus({
    required String status,
  });
}
