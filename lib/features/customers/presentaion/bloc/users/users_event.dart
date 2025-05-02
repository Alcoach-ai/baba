part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

class GetAllUsersEvent extends UsersEvent {}

class RefreshUsersEvent extends UsersEvent {}

class AddUserEvent extends UsersEvent {
  final User user;

  const AddUserEvent({required this.user});

  @override
  List<Object> get props => [user];
}

class DeleteUserEvent extends UsersEvent {
  final int userId;

  const DeleteUserEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateUserEvent extends UsersEvent {
  final User user;

  const UpdateUserEvent({required this.user});

  @override
  List<Object> get props => [user];
}
