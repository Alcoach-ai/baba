part of 'users_bloc.dart';

sealed class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

final class UsersInitial extends UsersState {}

class LoadingUsersSate extends UsersState {}

class LoadedUsersState extends UsersState {
  final List<User> users;

  const LoadedUsersState({required this.users});

  @override
  List<Object> get props => [users];
}

class ErrorUsersState extends UsersState {
  final String message;

  const ErrorUsersState({required this.message});

  @override
  List<Object> get props => [message];
}

class DoneUsersState extends UsersState {
  final String message;

  const DoneUsersState({required this.message});

  @override
  List<Object> get props => [message];
}
