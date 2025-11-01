import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/phone_verification_service.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_remote_data_source.dart';

// Firebase implementation for authentication
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw ServerException(message: 'Sign in failed. Please try again.');
      }

      // Get the ID token for authentication
      final String? token = await user.getIdToken();
      if (token == null) {
        throw ServerException(message: 'Failed to get authentication token.');
      }

      debugPrint('Firebase Sign In Success');
      return UserEntity(
        id: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? 'User',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Sign In Error: ${e.message}');
      String errorMessage = 'Sign in failed. Please try again.';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
      }
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('Unexpected Sign In Error: $e');
      throw ServerException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<UserEntity> signUp(String email, String password, String phone) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw ServerException(message: 'Sign up failed. Please try again.');
      }

      // Get the ID token for authentication
      final String? token = await user.getIdToken();
      if (token == null) {
        throw ServerException(message: 'Failed to get authentication token.');
      }

      debugPrint('Firebase Sign Up Success');
      return UserEntity(
        id: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? 'User',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Sign Up Error: ${e.message}');
      String errorMessage = 'Sign up failed. Please try again.';
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
      }
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('Unexpected Sign Up Error: $e');
      throw ServerException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> resetPasswordWithEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Firebase Reset Password (via email) Success for: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Reset Password Error: ${e.message}');
      String errorMessage = 'Password reset failed. Please try again.';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many reset attempts. Please try again later.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
      }
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('Unexpected Reset Password Error: $e');
      throw ServerException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> sendPhoneOtp(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('Phone verification completed automatically');
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed: ${e.message}');
          throw ServerException(message: 'Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('Phone OTP sent successfully');
          // Store verification ID for later use
          PhoneVerificationService.storeVerificationData(verificationId, phoneNumber);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Phone verification timeout');
        },
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Phone Auth Error: ${e.message}');
      String errorMessage = 'Failed to send OTP. Please try again.';
      
      switch (e.code) {
        case 'invalid-phone-number':
          errorMessage = 'Invalid phone number format.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many OTP requests. Please try again later.';
          break;
        case 'quota-exceeded':
          errorMessage = 'SMS quota exceeded. Please try again later.';
          break;
      }
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('Unexpected Phone Auth Error: $e');
      throw ServerException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> verifyPhoneOtp(String verificationId, String otp) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      await _firebaseAuth.signInWithCredential(credential);
      debugPrint('Phone OTP verification successful');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Phone OTP Verification Error: ${e.message}');
      String errorMessage = 'Invalid OTP. Please try again.';
      
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid verification code.';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Invalid verification ID.';
          break;
        case 'session-expired':
          errorMessage = 'Verification session expired. Please request a new OTP.';
          break;
      }
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('Unexpected Phone OTP Verification Error: $e');
      throw ServerException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> verifyOtp(String otp) async {
    // Keep dummy implementation for now
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp == '1234') {
      debugPrint('Simulated OTP Verification Success');
    } else {
      throw ServerException(message: 'Invalid OTP.');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        throw ServerException(message: 'Google sign-in was cancelled.');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      final User? user = userCredential.user;
      if (user == null) {
        throw ServerException(message: 'Google sign in failed. Please try again.');
      }
      
      // Get the ID token for authentication
      final String? token = await user.getIdToken();
      if (token == null) {
        throw ServerException(message: 'Failed to get authentication token.');
      }
      
      debugPrint('Google Sign In Success: ${user.email}');
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Google Sign In Error: ${e.message}');
      String errorMessage = 'Google sign in failed. Please try again.';
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with the same email but different sign-in credentials.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credential. Please try again.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled. Please contact support.';
          break;
      }
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('Unexpected Google Sign In Error: $e');
      throw ServerException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> setNewPassword(String newPassword) async {
    // Keep dummy implementation for now
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Simulated New Password Set Success');
  }
}
