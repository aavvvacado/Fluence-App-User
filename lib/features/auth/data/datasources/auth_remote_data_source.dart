import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(String email, String password, String phone);
  Future<void> resetPassword(String method);
  Future<void> verifyOtp(String otp);
  Future<void> setNewPassword(String newPassword);
}
