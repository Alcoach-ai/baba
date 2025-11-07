import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getAllUsers();

  Future<Either<Failure, Unit>> addUser(User user, bool isAddRemote);

  Future<Either<Failure, Unit>> updateUser(User user, bool isUpdateRemote);

  Future<Either<Failure, Unit>> deleteUser(String id, bool isDeleteRemote);
}
