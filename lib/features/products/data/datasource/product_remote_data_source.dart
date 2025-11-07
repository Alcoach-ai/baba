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
  Future<int> addProduct(ProductModel product);
  Future<int> updateProduct(ProductModel product);
  Future<int> deleteProduct(String id, String date);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DatabaseProvider databaseProvider;

  ProductRemoteDataSourceImpl({required this.databaseProvider});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final uri = Uri.parse(serverUrl).replace(queryParameters: {
      'target': "sheet2",
    });
    return await http.get(uri).then((response) {
      print(response.body);
      var jsonFeedback = jsonDecode(response.body) as List;
      print(jsonFeedback);
      return jsonFeedback
          .map((json) => ProductModel.fromJson(json))
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  Future<int> addProduct(ProductModel product) async {
    try {
      final response = await http.post(Uri.parse(serverUrl), headers: {
        'User-Agent':
            'Mozilla/5.0', // Trick Google into thinking it's a browser
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        'id': product.id,
        'name': product.name,
        'type': product.type,
        'weight': product.weight,
        'price': product.price,
        'date': product.date,
        'user_id': product.user_id,
        'lastupdate': product.lastupdate,
        'status': (product.status == '1' || product.status == '0') ? '0' : '3',
        "action": "add",
        "target": "sheet2"
      });
      if (kDebugMode) {
        print(response.statusCode);
        print('Body: ${response.body}');
      }
      if (response.statusCode == 200 || response.statusCode == 302) {
        return Future.value(1);
      } else {
        return Future.value(0);
      }
    } catch (e) {
      if (kDebugMode) {
        print("add product remote");
        print(e);
      }
      return Future.value(0);
    }
  }

  @override
  Future<int> updateProduct(ProductModel product) async {
    try {
      final response = await http.post(Uri.parse(serverUrl), headers: {
        'User-Agent':
            'Mozilla/5.0', // Trick Google into thinking it's a browser
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        'id': product.id,
        'name': product.name,
        'type': product.type,
        'weight': product.weight,
        'price': product.price,
        'date': product.date,
        'user_id': product.user_id,
        'lastupdate': product.lastupdate,
        'status': (product.status == '1' || product.status == '0') ? '0' : '3',
        "action": "update",
        "target": "sheet2"
      });
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200 || response.statusCode == 302) {
        return Future.value(1);
      } else {
        return Future.value(0);
      }
    } catch (e) {
      if (kDebugMode) {
        print("update product remote");
        print(e);
      }
      return Future.value(0);
    }
  }

  @override
  Future<int> deleteProduct(String id, String date) async {
    try {
      final response = await http.post(Uri.parse(serverUrl), body: {
        'id': id.toString(),
        "lastupdate": date,
        "action": "delete",
        "target": "sheet2"
      });
      if (kDebugMode) {
        print(response.statusCode);
        print('Body: ${response.body}');
      }
      if (response.statusCode == 200) {
        return Future.value(1);
      } else {
        return Future.value(0);
      }
    } catch (e) {
      if (kDebugMode) {
        print("del product remote");
        print(e);
      }
      return Future.value(0);
    }
  }
}
