import 'package:baba_bloc/core/database/database_provider.dart';
import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/features/customers/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

abstract class UserLocaleDataSource {
  Future<List<UserModel>> getAllUsers();
  Future<List<UserModel>> getNonSyncedUsers();
  Future<UserModel> getUser();
  Future<Unit> addUser(UserModel user);
  Future<Unit> updateUser(UserModel user);
  Future<Unit> deleteUser(int userId);
  Future<Unit> markUserSynced(int userId);
}

class UserLocaleDataSourceImpl implements UserLocaleDataSource {
  final DatabaseProvider databaseProvider;

  UserLocaleDataSourceImpl({required this.databaseProvider});

  @override
  Future<Unit> addUser(UserModel user) async {
    try {
      final db = await databaseProvider.database;
      await db!.insert('customer', user.toJson());
      return Future.value(unit);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Unit> deleteUser(int userId) async {
    try {
      final db = await databaseProvider.database;
      await db!.delete('customer', where: 'id = ?', whereArgs: [userId]);
      return Future.value(unit);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final db = await databaseProvider.database;
      final List<Map<String, dynamic>> users = await db!.query('customer');

      return users.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
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
          await db!.query('customer', limit: 1, orderBy: 'id DESC');

      return users.map((json) => UserModel.fromJson(json)).toList()[0];
    } catch (e) {
      if (kDebugMode) {
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
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Unit> markUserSynced(int userId) async {
    try {
      final db = await databaseProvider.database;

      await db!.rawUpdate(
          'UPDATE customer SET status = ? WHERE id = ?', ['0', userId]);
      return Future.value(unit);
    } catch (e) {
      throw CacheException();
    }
  }
}
