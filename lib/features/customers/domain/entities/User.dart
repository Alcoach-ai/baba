import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String name;
  final String status;
  final String lastupdate;

  const User(
      {this.id,
      required this.name,
      required this.status,
      required this.lastupdate});

  @override
  List<Object?> get props => [id, name, status, lastupdate];
}
