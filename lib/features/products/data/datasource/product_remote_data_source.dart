import 'dart:convert';

import 'package:baba_bloc/core/database/database_provider.dart';
import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/core/strings/urls.dart';
import 'package:baba_bloc/features/products/data/models/product_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<Unit> addProduct(ProductModel product);
  Future<Unit> updateUser(ProductModel product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DatabaseProvider databaseProvider;

  ProductRemoteDataSourceImpl({required this.databaseProvider});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    return await http.get(Uri.parse(serverUrl)).then((response) {
      var jsonFeedback = jsonDecode(response.body) as List;
      return jsonFeedback.map((json) => ProductModel.fromJson(json)).toList();
    });
  }

  @override
  Future<Unit> addProduct(ProductModel product) async {
    return await http.post(Uri.parse(serverUrl), body: {
      'id': id,
      'name': product.name,
      'type': product.type,
      'weight': product.weight,
      'price': product.price,
      'date': product.date,
      'user_id': product.user_id,
      "action": "add"
    }).then((response) async {
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        return Future.value(unit);
      } else {
        throw ServerException();
      }
    });
  }

  @override
  Future<Unit> updateUser(ProductModel product) async {
    return await http.post(Uri.parse(serverUrl), body: {
      'id': id,
      'name': product.name,
      'type': product.type,
      'weight': product.weight,
      'price': product.price,
      'date': product.date,
      'user_id': product.user_id,
      "action": "update"
    }).then((response) async {
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        return Future.value(unit);
      } else {
        throw ServerException();
      }
    });
  }
}
