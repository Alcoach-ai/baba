import 'package:baba_bloc/core/database/database_provider.dart';
import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/features/customers/data/models/user_model.dart';
import 'package:baba_bloc/features/products/data/datasource/product_locale_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

abstract class UserLocaleDataSource {
  Future<List<UserModel>> getAllUsers();
  Future<List<UserModel>> getNonSyncedUsers();
  Future<UserModel> getUser();
  Future<UserModel> getUserById(String id);
  Future<Unit> addUser(UserModel user);
  Future<Unit> updateUser(UserModel user);
  Future<Unit> deleteUser(String userId, String date);
  Future<Unit> markUserSynced(String userId, String statusId, String date);
}

class UserLocaleDataSourceImpl implements UserLocaleDataSource {
  final DatabaseProvider databaseProvider;

  UserLocaleDataSourceImpl({required this.databaseProvider});

  @override
  Future<Unit> addUser(UserModel user) async {
    try {
      final db = await databaseProvider.database;
      await db!.insert(
        'customer',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return Future.value(unit);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw CacheException('Username already exists');
      } else {
        throw CacheException('Database error: ${e.toString()}');
      }
    } catch (e) {
      throw CacheException('Unexpected error');
    }
  }

  @override
  Future<Unit> deleteUser(String userId, String date) async {
    try {
      final db = await databaseProvider.database;

      await db!.rawUpdate(
          'UPDATE customer SET name = ? , status = ? , lastupdate = ? WHERE id = ?',
          [userId + date, '2', date, userId]);

      return Future.value(unit);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final db = await databaseProvider.database;

      final result = await db!.rawQuery('''
      SELECT c.*, IFNULL(SUM(CAST(p.price AS INTEGER)), 0) AS total
      FROM customer c
      LEFT JOIN baba p 
        ON p.user_id = c.id AND (p.status = 0 OR p.status = 1)
      GROUP BY c.id
      ORDER BY c.lastupdate DESC
    ''');

      // final List<Map<String, dynamic>> users = await db!.query(
      //   'customer',
      //   orderBy: 'lastupdate DESC',
      // );
      return result.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("getting all users ");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> users = await db!.query(
        'customer',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (users.isEmpty) {
        throw CacheException('User not found');
      }

      return UserModel.fromJson(users.first);
    } catch (e) {
      if (kDebugMode) {
        print("getting user by id");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> users =
          await db!.query('customer', limit: 1, orderBy: 'lastupdate DESC');

      return users.map((json) => UserModel.fromJson(json)).toList()[0];
    } catch (e) {
      if (kDebugMode) {
        print("getting single user");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<List<UserModel>> getNonSyncedUsers() async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> users =
          await db!.query('customer', where: 'status = 1');

      return users.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("get non synced users");
        print(e);
      }
      throw CacheException();
    }
  }

  @override
  Future<Unit> updateUser(UserModel user) async {
    try {
      final db = await databaseProvider.database;

      await db!.update('customer', user.toJson(),
          where: 'id = ?', whereArgs: [user.id]);
      return Future.value(unit);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw CacheException('Username already exists');
      } else {
        throw CacheException('Database error: ${e.toString()}');
      }
    } catch (e) {
      throw CacheException('Unexpected error');
    }
  }

  @override
  Future<Unit> markUserSynced(
      String userId, String statusId, String date) async {
    try {
      final db = await databaseProvider.database;
      await db!.rawUpdate(
          'UPDATE customer SET status = ? , lastupdate = ? WHERE id = ?',
          [statusId, date, userId]);
      return Future.value(unit);
    } catch (e) {
      throw CacheException();
    }
  }
}
