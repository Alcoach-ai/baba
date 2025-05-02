import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/core/strings/failure.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/domain/usecases/add_user_use_case.dart';
import 'package:baba_bloc/features/customers/domain/usecases/delete_user_use_case.dart';
import 'package:baba_bloc/features/customers/domain/usecases/get_all_users_usecase.dart';
import 'package:baba_bloc/features/customers/domain/usecases/update_user_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetAllUsersUseCase getUsersUseCase;
  final AddUserUseCase addUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  UsersBloc(
      {required this.getUsersUseCase,
      required this.addUserUseCase,
      required this.updateUserUseCase,
      required this.deleteUserUseCase})
      : super(UsersInitial()) {
    on<UsersEvent>((event, emit) async {
      if (event is GetAllUsersEvent || event is RefreshUsersEvent) {
        loadUsers();
      } else if (event is AddUserEvent) {
        emit(LoadingUsersSate());
        final usersOrFailure = await addUserUseCase(event.user);
        emit(_eitherDoneOrErrorState(usersOrFailure, "Added"));
        loadUsers();
      } else if (event is UpdateUserEvent) {
        emit(LoadingUsersSate());
        final usersOrFailure = await updateUserUseCase(event.user);
        emit(_eitherDoneOrErrorState(usersOrFailure, "Updated"));
        loadUsers();
      }
    });
  }

  UsersState _eitherDoneOrErrorState(
      Either<Failure, Unit> either, String messgae) {
    return either.fold((failure) {
      return ErrorUsersState(message: _convertFailureToMessage(failure));
    }, (_) {
      return DoneUsersState(message: messgae);
    });
  }

  String _convertFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Please Try Again';
    }
  }

  Future<void> loadUsers() async {
    emit(LoadingUsersSate());
    final usersOrFailure = await getUsersUseCase();
    usersOrFailure.fold((failure) {
      emit(ErrorUsersState(message: _convertFailureToMessage(failure)));
    }, (users) {
      emit(LoadedUsersState(users: users));
    });
  }
}
