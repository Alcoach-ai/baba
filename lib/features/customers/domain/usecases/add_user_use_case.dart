import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/domain/repository/user_repository.dart';
import 'package:dartz/dartz.dart';

class AddUserUseCase {
  final UserRepository userRepository;

  AddUserUseCase(this.userRepository);

  Future<Either<Failure, Unit>> call(User user) async {
    return await userRepository.addUser(user, true);
  }
}
