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

  List<User> _allUsers = [];
  List<User> _displayedUsers = [];

  SortField _currentSortField = SortField.lastUpdate;
  SortOrder _currentSortOrder = SortOrder.descending;

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
        emit(_eitherDoneOrErrorState(usersOrFailure, "تمت الاضافة"));
        loadUsers();
      } else if (event is UpdateUserEvent) {
        emit(LoadingUsersSate());
        final usersOrFailure = await updateUserUseCase(event.user);
        emit(_eitherDoneOrErrorState(usersOrFailure, "تم التعديل"));
        loadUsers();
      } else if (event is DeleteUserEvent) {
        emit(LoadingUsersSate());
        final usersOrFailure = await deleteUserUseCase(event.userId);
        emit(_eitherDoneOrErrorState(usersOrFailure, "تم الحذف"));
        loadUsers();
      } else if (event is SearchUsersEvent) {
        //emit(LoadingUsersSate());
        List<User> filtered = _allUsers.where((u) {
          final lower = event.query.toLowerCase();
          return u.name.toLowerCase().contains(lower);
        }).toList();
        _displayedUsers = filtered;
        _applySort();
        emit(LoadedUsersState(users: _displayedUsers));
      } else if (event is SortUsersEvent) {
        _currentSortField = event.field;
        _currentSortOrder = event.order;

        _displayedUsers = List.from(_allUsers);
        _applySort();

        emit(LoadedUsersState(users: _displayedUsers));
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
    if (failure is CacheFailure && failure.message != null) {
      return failure.message!;
    }

    switch (failure.runtimeType) {
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'حدث خطأ، يرجى المحاولة لاحقًا';
    }
  }

  Future<void> loadUsers() async {
    emit(LoadingUsersSate());
    final usersOrFailure = await getUsersUseCase();
    usersOrFailure.fold((failure) {
      emit(ErrorUsersState(message: _convertFailureToMessage(failure)));
    }, (users) {
      _allUsers = users;
      _displayedUsers = List.from(_allUsers);
      _applySort();
      emit(LoadedUsersState(users: _displayedUsers));
    });
  }

  void _applySort() {
    _displayedUsers.sort((a, b) {
      int result;
      switch (_currentSortField) {
        case SortField.name:
          result = a.name.compareTo(b.name);
          break;
        case SortField.total:
          final totalA = a.total ?? 0;
          final totalB = b.total ?? 0;
          result = totalA.compareTo(totalB);
          break;
        case SortField.lastUpdate:
          final dateA = DateTime.tryParse(a.lastupdate) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = DateTime.tryParse(b.lastupdate) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          result = dateA.compareTo(dateB);
          break;
      }
      return _currentSortOrder == SortOrder.ascending ? result : -result;
    });
  }
}
