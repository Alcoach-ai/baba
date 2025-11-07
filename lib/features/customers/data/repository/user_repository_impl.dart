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
import 'package:uuid/uuid.dart';

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
      //localeUsers.forEach((item) {});
      final filteredUsers = localeUsers.where((product) {
        return product.status != '2' && product.status != '3';
      }).toList();
      localeUsers.forEach((item) {});
      return Right(filteredUsers);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addUser(User user, bool isAddRemote) async {
    final uuid = Uuid();
    UserModel userModel = UserModel(
        id: (!isAddRemote) ? user.id : uuid.v4(),
        name: user.name,
        status: user.status,
        lastupdate: user.lastupdate);

    final response = await _sendRequest(() async {
      final result = userLocaleDataSource.addUser(userModel);

      return result;
    });

    //if (isAddRemote) unawaited(_syncAddUserWithGoogleSheet(userModel));

    return response;
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(
      String id, bool isDeleteRemote) async {
    String date = DateTime.now().toUtc().toIso8601String();
    final response = await _sendRequest(() {
      return userLocaleDataSource.deleteUser(id, date);
    });

    //if (isDeleteRemote) unawaited(_syncDeleteUserWithGoogleSheet(id, date));

    return response;
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
    //if (isUpdateRemote) unawaited(_syncUpdateUserWithGoogleSheet(user));

    return response;
  }

  Future<Either<Failure, Unit>> _sendRequest(
      Future<Unit> Function() addUpdateDeleteUser) async {
    try {
      await addUpdateDeleteUser();
      return Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  void updateUserRemoteSide(UserModel user) async {
    try {
      int result = await userRemoteDataSource.updateUser(user);

      if (result == 1) {
        final localUser = await userLocaleDataSource.getUserById(user.id!);
        String statusToSet =
            (localUser.status == '2' || localUser.status == '3') ? '3' : '0';

        await userLocaleDataSource.markUserSynced(
            user.id!, statusToSet, user.lastupdate);
      }
    } on CacheException {
      if (kDebugMode) {
        print("Cache Exception");
      }
    }
  }

  void addUserRemoteSide(UserModel user) async {
    try {
      int result = await userRemoteDataSource.addUser(user);

      if (result == 1) {
        final localUser = await userLocaleDataSource.getUserById(user.id!);
        String statusToSet =
            (localUser.status == '2' || localUser.status == '3') ? '3' : '0';

        await userLocaleDataSource.markUserSynced(
            user.id!, statusToSet, user.lastupdate);
      }
    } on CacheException {
      if (kDebugMode) {
        print("Cache Exception");
      }
    }
  }

  // void updateAllUsersRemoteSide() async {
  //   try {
  //     final localeNonSyncedUsers = await userLocaleDataSource.getAllUsers();
  //     print("localeNonSyncedUsers " + localeNonSyncedUsers.length.toString());
  //     final remoteAllSyncedUsers = await userRemoteDataSource.getAllUsers();
  //     print("remoteAllSyncedUsers " + remoteAllSyncedUsers.length.toString());
  //     var remoteUsersMap = {
  //       for (var user in remoteAllSyncedUsers) user.id: user
  //     };

  //     // compare lastupdate
  //     for (var localeuser in localeNonSyncedUsers) {
  //       final remoteUser = remoteUsersMap[localeuser.id!];
  //       if (remoteUser != null) {
  //         final localeTime = DateTime.parse(localeuser.lastupdate);
  //         final remoteTime = DateTime.parse(remoteUser.lastupdate);
  //         if (localeTime.compareTo(remoteTime) > 0) {
  //           print("local is after remote");
  //           updateUserRemoteSide(localeuser);
  //         } else if (remoteTime.compareTo(localeTime) > 0) {
  //           print("remote is after locale");
  //           await updateUser(remoteUser, false);
  //         } else {
  //           if (kDebugMode) {
  //             print("user is up tp date ${localeuser.name}");
  //           }
  //         }
  //       } else {
  //         print("adding the user");
  //         addUserRemoteSide(localeuser);
  //       }
  //     }
  //     final localeUsersMap = {
  //       for (var user in localeNonSyncedUsers) user.id: user
  //     };
  //     // load the remote users
  //     for (var remoteuser in remoteAllSyncedUsers) {
  //       final localeUser = localeUsersMap[remoteuser.id!];
  //       if (localeUser != null) {
  //         final remoteTime = DateTime.parse(remoteuser.lastupdate);
  //         final localeTime = DateTime.parse(localeUser.lastupdate);
  //         if (localeTime.compareTo(remoteTime) > 0) {
  //           updateUserRemoteSide(localeUser);
  //         } else if (remoteTime.compareTo(localeTime) > 0) {
  //           await updateUser(remoteuser, false);
  //         } else {
  //           if (kDebugMode) {
  //             print("user is up tp date ${localeUser.name}");
  //           }
  //         }
  //       } else {
  //         await addUser(remoteuser, false);
  //         //addUserRemoteSide(remoteuser);
  //       }
  //     }

  //     remoteUsersMap = {for (var user in remoteAllSyncedUsers) user.id: user};

  //     // compare lastupdate
  //     for (var localeuser in localeNonSyncedUsers) {
  //       final remoteUser = remoteUsersMap[localeuser.id!];
  //       if (remoteUser != null) {
  //         final localeTime = DateTime.parse(localeuser.lastupdate);
  //         final remoteTime = DateTime.parse(remoteUser.lastupdate);
  //         if (localeTime.compareTo(remoteTime) > 0) {
  //           print("local is after remote");
  //           updateUserRemoteSide(localeuser);
  //         } else if (remoteTime.compareTo(localeTime) > 0) {
  //           print("remote is after locale");
  //           await updateUser(remoteUser, false);
  //         } else {
  //           if (kDebugMode) {
  //             print("user is up tp date ${localeuser.name}");
  //           }
  //         }
  //       } else {
  //         print("adding the user");
  //         addUserRemoteSide(localeuser);
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }

  Future<bool> updateAllUsersRemoteSide() async {
    bool newUpdateHappened = false;
    try {
      final localeUsers = await userLocaleDataSource.getAllUsers();
      final remoteUsers = await userRemoteDataSource.getAllUsers();
      final localeByName = {for (var user in localeUsers) user.name: user};

      // Create maps for fast lookup
      final remoteMap = {
        for (var user in remoteUsers) user.id.toString(): user
      };
      final localMap = {for (var user in localeUsers) user.id.toString(): user};

      // 1. Sync from remote to local
      for (var remoteUser in remoteUsers) {
        final localUser = localMap[remoteUser.id];

        // Safely parse date
        final remoteTime =
            DateTime.tryParse(remoteUser.lastupdate.toString()) ??
                DateTime.now();

        final localTime = localUser != null
            ? DateTime.tryParse(localUser.lastupdate.toString()) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0);

        if (localUser == null) {
          final localBySameName = localeByName[remoteUser.name];
          if (localBySameName != null) {
            // Merge: update local user’s ID to remote ID
            final mergedUser = localBySameName.copyWith(
                id: remoteUser.id, lastupdate: remoteUser.lastupdate);

            await updateUser(mergedUser, false); // update local DB
          } else {
            await addUser(remoteUser, false); // add to local
          }
          newUpdateHappened = true;
        } else if (remoteTime.isAfter(localTime)) {
          await updateUser(remoteUser, false); // update local
          newUpdateHappened = true;
        } else if (localTime.isAfter(remoteTime)) {
          updateUserRemoteSide(localUser); // update remote
        } else {
          //print("Up to date: ${localUser.name} ${localUser.lastupdate}");
        }
      }

      // 2. Sync from local to remote (new users not on server)
      for (var localUser in localeUsers) {
        final remoteUser = remoteMap[localUser.id];

        if (remoteUser == null) {
          addUserRemoteSide(localUser); // add to remote
        }
      }
    } catch (e) {
      print("Sync error: $e");
    }
    return newUpdateHappened;
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
            status: (user.status == '2' || user.status == '3') ? '3' : '0',
            lastupdate: user.lastupdate);
        await userLocaleDataSource.updateUser(SyncedUserModel);
      }
    } catch (e) {
      if (kDebugMode) {
        print("_syncUpdateUserWithGoogleSheet");
        print(e);
      }
    }
  }

  Future<void> _syncAddUserWithGoogleSheet(UserModel userModel) async {
    //UserModel userModel = await userLocaleDataSource.getUser();
    updateUserRemoteSide(userModel);
  }

  Future<void> _syncDeleteUserWithGoogleSheet(String id, String date) async {
    deleteUserRemoteSide(id, date);
  }

  void deleteUserRemoteSide(String id, String date) async {
    try {
      int result = await userRemoteDataSource.deleteUser(id, date);

      if (result == 1) {
        await userLocaleDataSource.markUserSynced(id, '3', date);
      }
    } on CacheException {
      if (kDebugMode) {
        print("Cache Exception");
      }
    }
  }
}
