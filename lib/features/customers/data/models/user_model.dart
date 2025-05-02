import 'package:baba_bloc/features/customers/domain/entities/User.dart';

class UserModel extends User {
  const UserModel(
      {super.id,
      required super.name,
      required super.status,
      required super.lastupdate});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        name: json['name'],
        status: json['status'],
        lastupdate: json['lastupdate']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'status': status, 'lastupdate': lastupdate};
  }
}
