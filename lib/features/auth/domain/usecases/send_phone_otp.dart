import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendPhoneOtp {
  final AuthRepository repository;

  SendPhoneOtp(this.repository);

  Future<Either<Failure, void>> call(String phoneNumber) async {
    return await repository.sendPhoneOtp(phoneNumber);
  }
}
