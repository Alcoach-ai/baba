import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final String type;
  final String weight;
  final String price;
  final String date;
  final int? user_id;

  Product(
      {this.id,
      required this.name,
      required this.type,
      required this.weight,
      required this.price,
      required this.date,
      required this.user_id});
  @override
  List<Object?> get props => [id, name, type, weight, price, date, user_id];
}
