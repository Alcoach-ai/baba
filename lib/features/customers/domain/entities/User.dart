import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id;
  final String name;
  final int? total;
  final String? status;
  final String lastupdate;

  const User(
      {this.id,
      required this.name,
      this.total,
      required this.status,
      required this.lastupdate});

  @override
  List<Object?> get props => [id, name, total, status, lastupdate];
}
