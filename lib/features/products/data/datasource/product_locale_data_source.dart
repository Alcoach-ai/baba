import 'package:baba_bloc/core/database/database_provider.dart';
import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/features/products/data/models/product_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

abstract class ProductLocaleDataSource {
  Future<List<ProductModel>> getAllProducts(String productId);
  Future<List<ProductModel>> getAllProductsToSync();
  Future<Unit> addProduct(ProductModel product);
  Future<List<ProductModel>> getNonSyncedProducts();
  Future<ProductModel> getProduct();
  Future<Unit> updateProduct(ProductModel product);
  Future<Unit> deleteProduct(String productId, String date);
  Future<int> getTotalUnPaid(String productId);
  Future<Unit> markProductSynced(String productId, String statusId);
}

class ProductLocaleDataSourceImpl implements ProductLocaleDataSource {
  final DatabaseProvider databaseProvider;
  final String PRODUCT_TABLE = "baba";

  ProductLocaleDataSourceImpl({required this.databaseProvider});

  @override
  Future<Unit> addProduct(ProductModel product) async {
    try {
      final db = await databaseProvider.database;
      await db!.insert(PRODUCT_TABLE, product.toJson());
      await db.rawUpdate('UPDATE customer SET lastupdate = ? WHERE id = ?',
          [product.lastupdate, product.user_id]);
      return Future.value(unit);
    } catch (e) {
      if (kDebugMode) {
        print("addProduct locale");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<Unit> deleteProduct(String userId, String date) async {
    try {
      final db = await databaseProvider.database;
      // 2 deleted but not syniched
      // 3 deleted and sinched
      await db!.rawUpdate(
          'UPDATE $PRODUCT_TABLE SET status = ?, lastupdate = ? WHERE id = ?',
          ['2', date, userId]);

      return Future.value(unit);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts(String userId) async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> products = await db!.query(
        PRODUCT_TABLE,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'lastupdate DESC',
      );

      return products.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("egt all products locale");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<List<ProductModel>> getAllProductsToSync() async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> products =
          await db!.query(PRODUCT_TABLE);

      return products.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("get all products to sync locale");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<ProductModel> getProduct() async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> products =
          await db!.query(PRODUCT_TABLE, limit: 1, orderBy: 'lastupdate DESC');

      return products.map((json) => ProductModel.fromJson(json)).toList()[0];
    } catch (e) {
      if (kDebugMode) {
        print("get one product locale");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<List<ProductModel>> getNonSyncedProducts() async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> users = await db!.query(
        PRODUCT_TABLE,
        where: 'status = ? OR status = ?',
        whereArgs: ['1', '2'],
      );

      return users.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("get non synced priducts locale");
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

      await db.rawUpdate('UPDATE customer SET lastupdate = ? WHERE id = ?',
          [product.lastupdate, product.user_id]);

      return Future.value(unit);
    } catch (e) {
      if (kDebugMode) {
        print("update product locale");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<int> getTotalUnPaid(String userId) async {
    try {
      final db = await databaseProvider.database;

      final result = await db!.rawQuery(
          'SELECT SUM(CAST(price AS INTEGER)) as total FROM ${PRODUCT_TABLE} WHERE user_id = ? AND status NOT IN ("2", "3")',
          [userId]);

      var total = result.first['total'];

      total ??= 0;

      return (total as int);
    } catch (e) {
      if (kDebugMode) {
        print("get total un paid locale");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<Unit> markProductSynced(String productId, String statusId) async {
    try {
      final db = await databaseProvider.database;

      await db!.rawUpdate('UPDATE $PRODUCT_TABLE SET status = ? WHERE id = ?',
          [statusId, productId]);
      return Future.value(unit);
    } catch (e) {
      throw CacheException();
    }
  }
}
