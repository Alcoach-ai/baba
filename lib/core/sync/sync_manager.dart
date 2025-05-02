import 'dart:async';
import 'dart:io';
import 'package:baba_bloc/features/customers/data/repository/user_repository_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncManager {
  final Connectivity connectivity;
  final UserRepositoryImpl userRepositoryImpl;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SyncManager({required this.connectivity, required this.userRepositoryImpl});

  void start() {
    _connectivitySubscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        Future.delayed(Duration(seconds: 4), () async {
          try {
            _updateAllData();
          } on SocketException catch (e) {
            print("Sync failed: $e");
          } on HandshakeException catch (e) {
            print("Handshake failed: $e");
          } catch (e) {
            print("Unexpected error: $e");
          }
        });
      }
    });
  }

  void syncOnAppStart() async {
    var results = await connectivity.checkConnectivity();
    if (results.isNotEmpty && results.first != ConnectivityResult.none) {
      _updateAllData();
    }
  }

  void stop() {
    _connectivitySubscription?.cancel();
  }

  void _updateAllData() {
    userRepositoryImpl.updateAllUsersRemoteSide();
  }
}
