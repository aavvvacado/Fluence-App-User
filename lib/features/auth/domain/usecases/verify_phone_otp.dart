import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtp {
  final AuthRepository repository;

  VerifyPhoneOtp(this.repository);

  Future<Either<Failure, void>> call(String verificationId, String otp) async {
    return await repository.verifyPhoneOtp(verificationId, otp);
  }
}
