import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/account_status_response.dart';
import '../repositories/auth_repository.dart';

class UpdateAccountStatus {
  final AuthRepository repository;

  UpdateAccountStatus(this.repository);

  Future<Either<Failure, AccountStatusResponse>> call({
    required String status,
  }) async {
    return await repository.updateAccountStatus(status: status);
  }
}
