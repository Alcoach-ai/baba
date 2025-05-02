import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/domain/repository/user_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateUserUseCase {
  final UserRepository userRepository;

  UpdateUserUseCase(this.userRepository);

  Future<Either<Failure, Unit>> call(User user) async {
    return await userRepository.updateUser(user, true);
  }
}
