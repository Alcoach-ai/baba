import 'dart:async';

import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/core/network/network_info.dart';
import 'package:baba_bloc/features/customers/data/datasources/user_locale_data_source.dart';
import 'package:baba_bloc/features/customers/data/datasources/user_remote_data_source.dart';
import 'package:baba_bloc/features/customers/data/models/user_model.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/domain/repository/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocaleDataSource userLocaleDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl(
      {required this.userLocaleDataSource,
      required this.userRemoteDataSource,
      required this.networkInfo});

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final localeUsers = await userLocaleDataSource.getAllUsers();

      return Right(localeUsers);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addUser(User user) async {
    UserModel userModel = UserModel(
        name: user.name, status: user.status, lastupdate: user.lastupdate);

    final response = await _sendRequest(() async {
      final result = userLocaleDataSource.addUser(userModel);

      return result;
    });

    unawaited(_syncAddUserWithGoogleSheet());

    return response;
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(int id) async {
    return await _sendRequest(() {
      return userLocaleDataSource.deleteUser(id);
    });
  }

  @override
  Future<Either<Failure, Unit>> updateUser(
      User user, bool isUpdateRemote) async {
    UserModel userModel = UserModel(
        id: user.id,
        name: user.name,
        status: user.status,
        lastupdate: user.lastupdate);

    final response = _sendRequest(() {
      return userLocaleDataSource.updateUser(userModel);
    });
    if (isUpdateRemote) unawaited(_syncUpdateUserWithGoogleSheet(user));

    return response;
  }

  Future<Either<Failure, Unit>> _sendRequest(
      Future<Unit> Function() addUpdateDeleteUser) async {
    try {
      await addUpdateDeleteUser();
      return Right(unit);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  void updateUserRemoteSide(UserModel user) async {
    try {
      int result = await userRemoteDataSource.updateUser(user);
      if (result == 1) {
        await userLocaleDataSource.markUserSynced(user.id!);
      }
    } on CacheException {
      if (kDebugMode) {
        print("Cache Exception");
      }
    }
  }

  void updateAllUsersRemoteSide() async {
    try {
      // load local users

      final localeNonSyncedUsers =
          await userLocaleDataSource.getNonSyncedUsers();
      if (kDebugMode) {
        print("not synced" + localeNonSyncedUsers.length.toString());
      }
      // load remote users

      final remoteAllSyncedUsers = await userRemoteDataSource.getAllUsers();

      final remoteUsersMap = {
        for (var user in remoteAllSyncedUsers) user.id: user
      };

      // compare lastupdate
      for (var localeuser in localeNonSyncedUsers) {
        final remoteUser = remoteUsersMap[localeuser.id!];
        if (remoteUser != null) {
          final localeTime = DateTime.parse(localeuser.lastupdate);
          final remoteTime = DateTime.parse(remoteUser.lastupdate);
          if (localeTime.isAfter(remoteTime)) {
            // push locale to remote
            updateUserRemoteSide(localeuser);
          } else if (remoteTime.isAfter(localeTime)) {
            // push remote to locale
            await updateUser(remoteUser, false);
          } else {
            if (kDebugMode) {
              print("user is up tp date ${localeuser.name}");
            }
          }
        }
      }

      // TODO
      // if conflict i update in offline mode and other device already update data

      // for (int i = 0; i < localeNonSyncedUsers.length; i++) {
      //   try {
      //     int result =
      //         await userRemoteDataSource.updateUser(localeNonSyncedUsers[i]);
      //     if (result == 1) {
      //       userLocaleDataSource.markUserSynced(localeNonSyncedUsers[i].id!);
      //     }
      //   } on CacheException {
      //     print("Cache Exception");
      //     break;
      //   }
      // }
      // } else {
      //   if (kDebugMode) {
      //     print("No Connection");
      //   }
      // }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _syncUpdateUserWithGoogleSheet(User user) async {
    try {
      int result = await userRemoteDataSource.updateUser(UserModel(
          id: user.id,
          name: user.name,
          status: user.status,
          lastupdate: user.lastupdate));

      if (result == 1) {
        UserModel SyncedUserModel = UserModel(
            id: user.id,
            name: user.name,
            status: "0",
            lastupdate: user.lastupdate);
        await userLocaleDataSource.updateUser(SyncedUserModel);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _syncAddUserWithGoogleSheet() async {
    UserModel userModel = await userLocaleDataSource.getUser();
    updateUserRemoteSide(userModel);
  }
}
