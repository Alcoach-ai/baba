import 'package:baba_bloc/features/customers/domain/entities/User.dart';

class UserModel extends User {
  const UserModel(
      {super.id,
      required super.name,
      super.total,
      required super.status,
      required super.lastupdate});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'].toString(),
        name: json['name'],
        total: json['total'],
        status: json['status'].toString(),
        lastupdate: json['lastupdate'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'status': status, 'lastupdate': lastupdate};
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? lastupdate,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastupdate: lastupdate ?? this.lastupdate,
      status: status ?? this.status,
    );
  }
}
