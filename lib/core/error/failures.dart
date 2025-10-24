import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List properties;

  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<Object?> get props => properties;
}

// General failures
class ServerFailure extends Failure {
  final String message;
  const ServerFailure({this.message = 'Server Error'});

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  final String message;
  const CacheFailure({this.message = 'Cache Error'});

  @override
  List<Object?> get props => [message];
}

// Auth specific failures
class InvalidCredentialsFailure extends Failure {
  final String message;
  const InvalidCredentialsFailure({
    this.message = 'Invalid email or password.',
  });

  @override
  List<Object?> get props => [message];
}

class UserNotFoundFailure extends Failure {
  final String message;
  const UserNotFoundFailure({this.message = 'User not found.'});

  @override
  List<Object?> get props => [message];
}
