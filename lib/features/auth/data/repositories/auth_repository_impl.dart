import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/api_auth_response.dart';
import '../../../../core/models/profile_completion_response.dart';
import '../../../../core/models/account_status_response.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/shared_preferences_service.dart';
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
      print('[AuthRepositoryImpl] Starting sign in for: $email');
      final user = await remoteDataSource.signIn(email, password);
      print('[AuthRepositoryImpl] Firebase sign in successful: $user');

      // Get Firebase ID token for API authentication
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();
        if (idToken != null) {
          print('[AuthRepositoryImpl] FULL Firebase ID token for $email: $idToken');
          print(
            '[AuthRepositoryImpl] Firebase ID token obtained: ${idToken.substring(0, 20)}...',
          );

          // Call API service for backend authentication
          try {
            final apiResponse = await ApiService.authenticateWithFirebase(
              idToken: idToken,
            );
            print('[AuthRepositoryImpl] API response received: $apiResponse');

            final authResponse = ApiAuthResponse.fromJson(apiResponse);
            print('[AuthRepositoryImpl] Parsed auth response: $authResponse');

            // Check user role - only allow users with "user" role
            if (authResponse.user.role != 'user') {
              print('[AuthRepositoryImpl] Access denied for role: ${authResponse.user.role}');
              return Left(UnauthorizedAccessFailure(
                message: 'Access denied. Only regular users can access this application.',
              ));
            }

            // Save API response data to shared preferences
            await SharedPreferencesService.saveUserData(
              userId: authResponse.user.id,
              email: authResponse.user.email,
              name: authResponse.user.name,
            );
            await SharedPreferencesService.saveToken(authResponse.token);
            await SharedPreferencesService.setNeedsProfileCompletionFlag(authResponse.needsProfileCompletion == true);

            print('[AuthRepositoryImpl] API user data saved to shared preferences');
            print('[AuthRepositoryImpl] JWT Token: ${authResponse.token.substring(0, 20)}...');
            print('[AuthRepositoryImpl] Needs Profile Completion: ${authResponse.needsProfileCompletion}');

            // Return the API user data
            final apiUserEntity = UserEntity(
              id: authResponse.user.id,
              email: authResponse.user.email,
              name: authResponse.user.name,
            );

            return Right(apiUserEntity);
          } catch (apiError) {
            print('[AuthRepositoryImpl] API authentication failed: $apiError');
            // Fallback to Firebase-only authentication
            final tokenResult = await getAuthToken();
            tokenResult.fold((failure) => null, (token) {
              if (token != null) {
                SharedPreferencesService.saveToken(token);
                SharedPreferencesService.saveUserData(
                  userId: user.id,
                  email: user.email,
                  name: user.name,
                );
              }
            });
            return Right(user);
          }
        } else {
          print('[AuthRepositoryImpl] No Firebase ID token available');
          // Fallback to Firebase-only authentication
          final tokenResult = await getAuthToken();
          tokenResult.fold(
            (failure) => null,
            (token) {
              if (token != null) {
                SharedPreferencesService.saveToken(token);
                SharedPreferencesService.saveUserData(
                  userId: user.id,
                  email: user.email,
                  name: user.name,
                );
              }
            },
          );
          return Right(user);
        }
      } else {
        print('[AuthRepositoryImpl] No Firebase user found, using local result');
        final tokenResult = await getAuthToken();
        tokenResult.fold(
          (failure) => null,
          (token) {
            if (token != null) {
              SharedPreferencesService.saveToken(token);
              SharedPreferencesService.saveUserData(
                userId: user.id,
                email: user.email,
                name: user.name,
              );
            }
          },
        );
        return Right(user);
      }
    } on ServerException catch (e) {
      print('[AuthRepositoryImpl] Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      print('[AuthRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred'));
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
      print('[AuthRepositoryImpl] Starting sign up for: $email');
      final user = await remoteDataSource.signUp(email, password, phone);
      print('[AuthRepositoryImpl] Firebase sign up successful: $user');

      // Get Firebase ID token for API authentication
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();
        if (idToken != null) {
          print('[AuthRepositoryImpl] FULL Firebase ID token for $email: $idToken');
          print(
            '[AuthRepositoryImpl] Firebase ID token obtained: ${idToken.substring(0, 20)}...',
          );

          // Call API service for backend authentication
          try {
            final apiResponse = await ApiService.authenticateWithFirebase(
              idToken: idToken,
            );
            print('[AuthRepositoryImpl] API response received: $apiResponse');

            final authResponse = ApiAuthResponse.fromJson(apiResponse);
            print('[AuthRepositoryImpl] Parsed auth response: $authResponse');

            // Save API response data to shared preferences
            await SharedPreferencesService.saveUserData(
              userId: authResponse.user.id,
              email: authResponse.user.email,
              name: authResponse.user.name,
            );
            await SharedPreferencesService.saveToken(authResponse.token);
            await SharedPreferencesService.setNeedsProfileCompletionFlag(authResponse.needsProfileCompletion == true);

            print('[AuthRepositoryImpl] API user data saved to shared preferences');
            print('[AuthRepositoryImpl] JWT Token: ${authResponse.token.substring(0, 20)}...');
            print('[AuthRepositoryImpl] Needs Profile Completion: ${authResponse.needsProfileCompletion}');

            // Return the API user data
            final apiUserEntity = UserEntity(
              id: authResponse.user.id,
              email: authResponse.user.email,
              name: authResponse.user.name,
            );

            return Right(apiUserEntity);
          } catch (apiError) {
            print('[AuthRepositoryImpl] API authentication failed: $apiError');
            // Fallback to Firebase-only authentication
            final tokenResult = await getAuthToken();
            tokenResult.fold((failure) => null, (token) {
              if (token != null) {
                SharedPreferencesService.saveToken(token);
                SharedPreferencesService.saveUserData(
                  userId: user.id,
                  email: user.email,
                  name: user.name,
                );
              }
            });
            return Right(user);
          }
        } else {
          print('[AuthRepositoryImpl] No Firebase ID token available');
          // Fallback to Firebase-only authentication
          final tokenResult = await getAuthToken();
          tokenResult.fold(
            (failure) => null,
            (token) {
              if (token != null) {
                SharedPreferencesService.saveToken(token);
                SharedPreferencesService.saveUserData(
                  userId: user.id,
                  email: user.email,
                  name: user.name,
                );
              }
            },
          );
          return Right(user);
        }
      } else {
        print('[AuthRepositoryImpl] No Firebase user found, using local result');
        final tokenResult = await getAuthToken();
        tokenResult.fold(
          (failure) => null,
          (token) {
            if (token != null) {
              SharedPreferencesService.saveToken(token);
              SharedPreferencesService.saveUserData(
                userId: user.id,
                email: user.email,
                name: user.name,
              );
            }
          },
        );
        return Right(user);
      }
    } on ServerException catch (e) {
      print('[AuthRepositoryImpl] Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      print('[AuthRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  // --- Password Recovery Implementation ---
  @override
  Future<Either<Failure, void>> resetPasswordWithEmail(String email) async {
    try {
      await remoteDataSource.resetPasswordWithEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPhoneOtp(String phoneNumber) async {
    try {
      await remoteDataSource.sendPhoneOtp(phoneNumber);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPhoneOtp(String verificationId, String otp) async {
    try {
      await remoteDataSource.verifyPhoneOtp(verificationId, otp);
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

  // --- Logout Implementation ---
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Logout failed. Please try again.'));
    }
  }

  // --- Get Current User Implementation ---
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }

      final user = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'User',
      );

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user.'));
    }
  }

  // --- Get Auth Token Implementation ---
  @override
  Future<Either<Failure, String?>> getAuthToken() async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }

      final String? token = await firebaseUser.getIdToken();
      return Right(token);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get auth token.'));
    }
  }

  // --- Complete Profile Implementation ---
  @override
  Future<Either<Failure, ProfileCompletionResponse>> completeProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
    required String email,
  }) async {
    try {
      print('[AuthRepositoryImpl] Starting profile completion for: $name, $email, $phone, $dateOfBirth');
      // Get the stored JWT token from shared preferences
      final authToken = SharedPreferencesService.getAuthToken();
      if (authToken == null) {
        print('[AuthRepositoryImpl] No auth token found');
        return Left(ServerFailure(message: 'No authentication token found. Please log in again.'));
      }
      // Call API service for profile completion
      final apiResponse = await ApiService.completeProfile(
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        email: email,
        authToken: authToken,
      );
      print('[AuthRepositoryImpl] Profile completion API response: $apiResponse');
      final profileResponse = ProfileCompletionResponse.fromJson(apiResponse);
      print('[AuthRepositoryImpl] Parsed profile completion response: $profileResponse');
      return Right(profileResponse);
    } on ServerException catch (e) {
      print('[AuthRepositoryImpl] Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      print('[AuthRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  // --- Update Account Status Implementation ---
  @override
  Future<Either<Failure, AccountStatusResponse>> updateAccountStatus({
    required String status,
  }) async {
    try {
      print('[AuthRepositoryImpl] Starting account status update to: $status');
      
      // Get the stored JWT token from shared preferences
      final authToken = SharedPreferencesService.getAuthToken();
      if (authToken == null) {
        print('[AuthRepositoryImpl] No auth token found');
        return Left(ServerFailure(message: 'No authentication token found. Please log in again.'));
      }

      // Call API service for account status update
      final apiResponse = await ApiService.updateAccountStatus(
        status: status,
        authToken: authToken,
      );
      
      print('[AuthRepositoryImpl] Account status update API response: $apiResponse');
      
      final statusResponse = AccountStatusResponse.fromJson(apiResponse);
      print('[AuthRepositoryImpl] Parsed account status response: $statusResponse');
      
      return Right(statusResponse);
    } on ServerException catch (e) {
      print('[AuthRepositoryImpl] Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      print('[AuthRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }
}