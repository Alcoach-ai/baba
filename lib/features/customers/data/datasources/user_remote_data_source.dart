import 'dart:convert';

import 'package:baba_bloc/core/strings/urls.dart';
import 'package:baba_bloc/features/customers/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers();

  Future<int> addUser(UserModel user);
  Future<int> updateUser(UserModel user);
  Future<int> deleteUser(String id, String date);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl();

  @override
  Future<List<UserModel>> getAllUsers() async {
    // try {
    return await http.get(Uri.parse(serverUrl)).then((response) {
      var jsonFeedback = jsonDecode(response.body) as List;
      print("=======================");
      print("getting data from online ");
      print(response.body);
      print("=======================");
      return jsonFeedback
          .map((json) => UserModel.fromJson(json))
          .toList()
          .reversed
          .toList();
    });
    // } catch (e) {
    //   if (kDebugMode) {
    //     print("getting all remote users");
    //     print(e);
    //   }
    //   return Future.value([]);
    // }
  }

  @override
  Future<int> addUser(UserModel user) async {
    try {
      final response = await http.post(Uri.parse(serverUrl), headers: {
        'User-Agent':
            'Mozilla/5.0', // Trick Google into thinking it's a browser
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        'id': user.id,
        'name': user.name,
        'lastupdate': user.lastupdate,
        'status': (user.status == '1' || user.status == '0') ? '0' : '3',
        "action": "add"
      });

      if (kDebugMode) {
        //print('Status Code: ${response.statusCode}');
        //print('Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 302) {
        return Future.value(1);
      } else {
        return Future.value(0);
      }
    } catch (e) {
      if (kDebugMode) {
        print("adding user to remote side");
        print(e);
      }
      return Future.value(0);
    }
  }

  @override
  Future<int> updateUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0', // Trick Google into thinking it's a browser
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'id': user.id,
          'name': user.name,
          'lastupdate': user.lastupdate,
          'status': (user.status == '1' || user.status == '0') ? '0' : '3',
          'action': 'update',
        },
      );

      if (kDebugMode) {
        //print('Status Code: ${response.statusCode}');
        //print('Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 302) {
        return Future.value(1);
      } else {
        return Future.value(0);
      }
    } catch (e) {
      if (kDebugMode) {
        print("updating user remote side");
        print(e);
      }
      return Future.value(0);
    }
  }

  @override
  Future<int> deleteUser(String id, String date) async {
    try {
      final response = await http.post(Uri.parse(serverUrl), body: {
        'id': id.toString(),
        "lastupdate": date,
        "action": "delete",
        "target": "sheet1"
      });
      if (kDebugMode) {
        //print(response.statusCode);
        //print('Body: ${response.body}');
      }
      if (response.statusCode == 200) {
        return Future.value(1);
      } else {
        return Future.value(0);
      }
    } catch (e) {
      if (kDebugMode) {
        print("deleting user remote side");
        print(e);
      }
      return Future.value(0);
    }
  }
}
