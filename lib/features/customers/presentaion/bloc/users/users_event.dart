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
  final String userId;

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

class SearchUsersEvent extends UsersEvent {
  final String query;
  const SearchUsersEvent(this.query);

  @override
  List<Object> get props => [query];
}

enum SortField { name, total, lastUpdate }

enum SortOrder { ascending, descending }

class SortUsersEvent extends UsersEvent {
  final SortField field;
  final SortOrder order;
  const SortUsersEvent(this.field, this.order);

  @override
  List<Object> get props => [field, order];
}
