import 'package:path/path.dart';

// static final DatabaseProvider _instance = DatabaseProvider._internal();

// factory DatabaseProvider() => _instance;

// DatabaseProvider._internal();

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert' as convert;

import 'package:uuid/uuid.dart';

class DatabaseProvider {
  static final _databaseName = "baba.db";
  static final _databaseVersion = 3;

  static final table = 'baba';
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
  static final customer_status = 'status';
  static final customer_last_update = 'lastupdate';

  List<String> tables = [table, table_customer];

  final uuid = Uuid();

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

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // bool exist = await databaseExists(path);
    // if (exist == true) {
    //   return await openDatabase(path, version: _databaseVersion);
    // } else {
    //   return await openDatabase(path,
    //       version: _databaseVersion, onCreate: _onCreate);
    // }
  }

  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $Id TEXT PRIMARY KEY,
            $Name TEXT,
            $type TEXT,
            $weight TEXT,
            $price TEXT,
            $Date TEXT,
            $customer_id TEXT,
            $customer_status TEXT,
            $customer_last_update TEXT
          )
          ''');

    await db.execute('''
        CREATE TABLE $table_customer (
          $c_id TEXT PRIMARY KEY,
          $c_name TEXT UNIQUE,
          $c_status TEXT,
          $c_last_update TEXT)
          ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Rename old baba table
      await db.execute('ALTER TABLE $table RENAME TO baba_old');

      // Create new baba table with TEXT id and additional columns
      await db.execute('''
      CREATE TABLE $table (
        $Id TEXT PRIMARY KEY,
            $Name TEXT,
            $type TEXT,
            $weight TEXT,
            $price TEXT,
            $Date TEXT,
            $customer_id TEXT,
            $customer_status TEXT DEFAULT "1",
            $customer_last_update TEXT 
      )
    ''');

      await db.execute('ALTER TABLE $table_customer RENAME TO customer_old');

      await db.execute('''
        CREATE TABLE $table_customer (
          $c_id TEXT PRIMARY KEY,
          $c_name TEXT UNIQUE ,
          $c_status TEXT DEFAULT "1",
          $c_last_update TEXT )
          ''');
      // Read old data
      List<Map<String, dynamic>> oldData = await db.query('baba_old');
      List<Map<String, dynamic>> oldCustomer = await db.query('customer_old');
      final now = DateTime.now()
          .toUtc()
          .toIso8601String(); // e.g., 2025-08-08T12:52:48.646810Z

      // Insert with new UUIDs
      for (var row in oldData) {
        await db.insert(table, {
          Id: uuid.v4(),
          Name: row['type'] ?? '',
          type: row['name'] ?? '',
          weight: row['weight'] ?? '',
          price: row['price'] ?? '',
          Date: row['date'] ?? '',
          customer_id: row['customer_id'].toString(),
          customer_last_update: now,
        });
      }
      final Set<String> existingNames = {};
      for (var row in oldCustomer) {
        String baseName = row['name']?.toString().trim() ?? '';
        if (baseName.isEmpty) {
          baseName = 'بدون اسم';
        }
        String name = baseName;
        int suffix = 1;

        while (
            existingNames.contains(name) || await _nameExistsInDb(db, name)) {
          name = '$baseName($suffix)';
          suffix++;
        }

        existingNames.add(name);

        await db.insert(table_customer, {
          c_id: row['id'].toString(),
          c_name: name,
          c_last_update: now,
        });
      }

      // Drop old table
      await db.execute('DROP TABLE baba_old');
      await db.execute('DROP TABLE customer_old');

      // Alter customer table
      // await db.execute('ALTER TABLE $table ADD COLUMN status TEXT DEFAULT "0"');
      // await db.execute(
      //     'ALTER TABLE $table ADD COLUMN lastupdate TEXT DEFAULT CURRENT_TIMESTAMP');

      // await db.execute(
      //     'ALTER TABLE $table_customer ADD COLUMN status TEXT DEFAULT "0"');
      // await db.execute(
      //     'ALTER TABLE $table_customer ADD COLUMN lastupdate TEXT DEFAULT CURRENT_TIMESTAMP');
    }
  }

  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     // Example: add new columns
  //     await db.execute(
  //         'ALTER TABLE $table ADD COLUMN $customer_status TEXT DEFAULT "0"');
  //     await db.execute(
  //         'ALTER TABLE $table ADD COLUMN $customer_last_update TEXT DEFAULT CURRENT_TIMESTAMP');

  //     await db.execute(
  //         'ALTER TABLE $table_customer ADD COLUMN $c_status TEXT DEFAULT "0"');
  //     await db.execute(
  //         'ALTER TABLE $table_customer ADD COLUMN $c_last_update TEXT DEFAULT CURRENT_TIMESTAMP');
  //   }

  //   // Future migrations:
  //   // if (oldVersion < 3) { ... }
  // }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert1(String name, String status) async {
    Database? db = await instance.database;
    return await db!.insert(table_customer, {'name': name, 'status': status});
  }

  Future<bool> _nameExistsInDb(Database db, String name) async {
    final result = await db.query(
      table_customer,
      where: '$c_name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return result.isNotEmpty;
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
