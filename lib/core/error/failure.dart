import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List properties;
  const Failure([this.properties = const []]);

  // @override
  // List<Object> get props => [...properties];
}

class CacheFailure extends Failure {
  final String? message;
  CacheFailure([this.message]) : super([message]);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NetworkFailure extends Failure {
  @override
  List<Object?> get props => [];
}
