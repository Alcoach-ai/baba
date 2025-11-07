import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/customers/domain/repository/user_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteUserUseCase {
  final UserRepository userRepository;

  DeleteUserUseCase(this.userRepository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await userRepository.deleteUser(userId, true);
  }
}
