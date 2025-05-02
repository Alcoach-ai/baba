import 'dart:convert';

import 'package:baba_bloc/core/strings/urls.dart';
import 'package:baba_bloc/features/customers/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers();

  Future<Unit> addUser(UserModel user);
  Future<int> updateUser(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl();

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      return await http.get(Uri.parse(serverUrl)).then((response) {
        var jsonFeedback = jsonDecode(response.body) as List;
        return jsonFeedback.map((json) => UserModel.fromJson(json)).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Future.value([]);
    }
  }

  @override
  Future<Unit> addUser(UserModel user) async {
    try {
      return await http.post(Uri.parse(serverUrl), body: {
        'id': user.id,
        'name': user.name,
        'lastupdate': user.lastupdate,
        "action": "add"
      }).then((response) async {
        if (kDebugMode) {
          print(response.statusCode);
        }
        if (response.statusCode == 200) {
          return Future.value(unit);
        } else {
          if (kDebugMode) {
            print(response.body);
          }
          return Future.value(unit);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Future.value(unit);
    }
  }

  @override
  Future<int> updateUser(UserModel user) async {
    try {
      final request = http.Request('POST', Uri.parse(serverUrl))
        ..headers['Content-Type'] = 'application/x-www-form-urlencoded'
        ..bodyFields = {
          'id': user.id.toString(),
          'name': user.name,
          'lastupdate': user.lastupdate,
          "action": "update"
        };

      final client = http.Client();
      return await client.send(request).then((response) async {
        if (kDebugMode) {
          print(response.statusCode);
        }
        if (response.statusCode == 200) {
          return Future.value(1);
        } else {
          if (kDebugMode) {
            print(response.stream.bytesToString());
          }
          return Future.value(0);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Future.value(0);
    }
  }
}
