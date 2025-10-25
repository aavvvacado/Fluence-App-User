import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/profile_completion_response.dart';
import '../repositories/auth_repository.dart';

class CompleteProfile {
  final AuthRepository repository;

  CompleteProfile(this.repository);

  Future<Either<Failure, ProfileCompletionResponse>> call({
    required String name,
    required String phone,
    required String dateOfBirth,
    required String email,
  }) async {
    return await repository.completeProfile(
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
      email: email,
    );
  }
}
