import 'package:path/path.dart';

// static final DatabaseProvider _instance = DatabaseProvider._internal();

// factory DatabaseProvider() => _instance;

// DatabaseProvider._internal();

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert' as convert;

class DatabaseProvider {
  static final _databaseName = "baba.db";
  static final _databaseVersion = 2;

  static final table = 'products';
  static final table_customer = 'customer';

  static final c_id = 'id';
  static final c_name = 'name';
  static final c_status = 'status';
  static final c_last_update = 'lastupdate';

  static final Id = 'id';
  static final Name = 'name';
  static final type = 'type';
  static final weight = 'weight';
  static final price = 'price';
  static final Date = 'date';
  static final customer_id = 'user_id';

  List<String> tables = [table, table_customer];

  // DatabaseProvider._privateConstructor();
  // static final DatabaseProvider instance =
  //     DatabaseProvider._privateConstructor();

  static final DatabaseProvider instance = DatabaseProvider._instance();
  DatabaseProvider._instance();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    bool exist = await databaseExists(path);
    if (exist == true) {
      return await openDatabase(path, version: _databaseVersion);
    } else {
      return await openDatabase(path,
          version: _databaseVersion, onCreate: _onCreate);
    }
  }

  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $Id INTEGER PRIMARY KEY AUTOINCREMENT,
            $Name TEXT NOT NULL,
            $type TEXT,
            $weight TEXT,
            $price TEXT,
            $Date TEXT,
            $customer_id INTEGER
          )
          ''');

    await db.execute('''
        CREATE TABLE $table_customer (
          $c_id INTEGER PRIMARY KEY AUTOINCREMENT,
          $c_name TEXT NOT NULL,
          $c_status TEXT NOT NULL,
          $c_last_update TEXT NOT NULL)
          ''');
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert1(String name, String status) async {
    Database? db = await instance.database;
    return await db!.insert(table_customer, {'name': name, 'status': status});
  }

  // Future<int> insert(baba rem) async {
  //   Database? db = await instance.database;
  //   return await db!.insert(table, {
  //     'name': rem.name,
  //     'type': rem.type,
  //     'weight': rem.weight,
  //     'price': rem.price,
  //     'date': rem.date,
  //     'customer_id': rem.customer_id
  //   });
  // }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, Object?>>> queryAllRows(int id) async {
    Database? db = await instance.database;
    return await db!.query(table, where: '$customer_id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> queryAllRow() async {
    Database? db = await instance.database;
    return await db!.query(table_customer);
  }

  Future<List<Map<String, Object?>>> queryAllRow1() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }
  // Queries rows based on the argument received
  // Future<List<Map<String, dynamic>>> queryRows(name) async {
  //   Database db = await instance.database;
  //   return await db.query(table, where: "$columnName LIKE '%$name%'");
  // }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  // Future<int> update(baba rem) async {
  //   Database? db = await instance.database;
  //   int id = rem.id;
  //   return await db!
  //       .update(table, rem.toMap(), where: '$Id = ?', whereArgs: [id]);
  // }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$Id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    Database? db = await instance.database;
    await db!.rawQuery('Drop table baba');

    await db.rawQuery('Drop table customer');
    await _onCreate(db, _databaseVersion);
  }

  Future<List<Map<String, Object?>>> search(String text, int id) async {
    Database? db = await instance.database;
    return await db!.rawQuery(
        "SELECT * FROM baba WHERE type LIKE '%$text%' AND customer_id=$id ");
  }

  Future<List<Map<String, Object?>>> search1(String text) async {
    Database? db = await instance.database;
    return await db!.rawQuery(
        "select customer.id , customer.name , customer.status from customer,baba where customer.id=baba.customer_id and baba.type like '%$text%' ");
  }
}
