import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/domain/repository/user_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllUsersUseCase {
  final UserRepository userRepository;

  GetAllUsersUseCase(this.userRepository);

  Future<Either<Failure, List<User>>> call() async {
    return await userRepository.getAllUsers();
  }
}
