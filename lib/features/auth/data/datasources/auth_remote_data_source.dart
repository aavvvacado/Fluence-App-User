import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(String email, String password, String phone);
  Future<UserEntity> signInWithGoogle();
  Future<void> resetPasswordWithEmail(String email);
  Future<void> sendPhoneOtp(String phoneNumber);
  Future<void> verifyPhoneOtp(String verificationId, String otp);
  Future<void> verifyOtp(String otp);
  Future<void> setNewPassword(String newPassword);
}
