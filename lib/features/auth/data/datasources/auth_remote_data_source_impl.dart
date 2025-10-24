import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_remote_data_source.dart';

// Dummy implementation that simulates network delay and success/failure.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserEntity> signIn(String email, String password) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call

    // Dummy logic for success/failure
    if (email == 'test@fluence.com' && password == '1234') {
      debugPrint('Simulated Sign In Success');
      return const UserEntity(
        id: '123',
        email: 'test@fluence.com',
        name: 'Romina',
      );
    } else {
      debugPrint('Simulated Sign In Failure');
      throw ServerException(message: 'Invalid credentials.');
    }
  }

  @override
  Future<UserEntity> signUp(String email, String password, String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Simulated Sign Up Success');
    return const UserEntity(
      id: '124',
      email: 'new@fluence.com',
      name: 'New User',
    );
  }

  @override
  Future<void> resetPassword(String method) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Simulated Reset Password (via $method) Success');
  }

  @override
  Future<void> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp == '1234') {
      debugPrint('Simulated OTP Verification Success');
    } else {
      throw ServerException(message: 'Invalid OTP.');
    }
  }

  @override
  Future<void> setNewPassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Simulated New Password Set Success');
  }
}
