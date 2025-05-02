import 'package:baba_bloc/core/database/database_provider.dart';
import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/features/products/data/models/product_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

abstract class ProductLocaleDataSource {
  Future<List<ProductModel>> getAllProducts(int userId);
  Future<Unit> addProduct(ProductModel product);
  Future<Unit> updateProduct(ProductModel product);
  Future<Unit> deleteProduct(int userId);
  Future<int> getTotalUnPaid(int userId);
}

class ProductLocaleDataSourceImpl implements ProductLocaleDataSource {
  final DatabaseProvider databaseProvider;
  final String PRODUCT_TABLE = "products";

  ProductLocaleDataSourceImpl({required this.databaseProvider});

  @override
  Future<Unit> addProduct(ProductModel product) async {
    try {
      final db = await databaseProvider.database;
      await db!.insert(PRODUCT_TABLE, product.toJson());
      return Future.value(unit);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<Unit> deleteProduct(int userId) async {
    try {
      final db = await databaseProvider.database;
      await db!.delete(PRODUCT_TABLE, where: 'id = ?', whereArgs: [userId]);
      return Future.value(unit);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts(int userId) async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> products = await db!
          .query(PRODUCT_TABLE, where: 'user_id = ?', whereArgs: [userId]);

      return products.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<Unit> updateProduct(ProductModel product) async {
    try {
      final db = await databaseProvider.database;

      await db!.update(PRODUCT_TABLE, product.toJson(),
          where: 'id = ?', whereArgs: [product.id]);
      return Future.value(unit);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<int> getTotalUnPaid(int userId) async {
    try {
      final db = await databaseProvider.database;

      final result = await db!.rawQuery(
          'SELECT SUM(CAST(price AS INTEGER)) as total FROM ${PRODUCT_TABLE} WHERE user_id = $userId');

      final total = result.first['total'];

      return (total as int);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw CacheException();
    }
  }
}
