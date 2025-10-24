import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  // This is the function called by the BLoC to execute the sign-up logic.
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(params.email, params.password, params.phone);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String phone;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, phone];
}
