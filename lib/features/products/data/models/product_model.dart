import 'package:baba_bloc/features/products/domain/entities/Product.dart';

class ProductModel extends Product {
  ProductModel(
      {super.id,
      required super.name,
      required super.type,
      required super.weight,
      required super.price,
      required super.date,
      required super.user_id});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        weight: json['weight'],
        price: json['price'],
        date: json['date'],
        user_id: json['user_id']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'weight': weight,
      'price': price,
      'date': date,
      'user_id': user_id
    };
  }
}
