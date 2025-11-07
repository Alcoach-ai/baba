import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String? id;
  final String name;
  final String? type;
  final String weight;
  final String price;
  final String date;
  final String? user_id;
  final String? status;
  final String lastupdate;

  Product(
      {this.id,
      required this.name,
      required this.type,
      required this.weight,
      required this.price,
      required this.date,
      required this.user_id,
      required this.status,
      required this.lastupdate});
  @override
  List<Object?> get props =>
      [id, name, type, weight, price, date, user_id, status, lastupdate];
}
