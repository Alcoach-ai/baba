import 'dart:async';
import 'dart:io';
import 'package:baba_bloc/features/customers/data/repository/user_repository_impl.dart';
import 'package:baba_bloc/features/customers/presentaion/bloc/users/users_bloc.dart';
import 'package:baba_bloc/features/products/data/repository/product_repository_impl.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

class SyncManager {
  final Connectivity connectivity;
  final UserRepositoryImpl userRepositoryImpl;
  final ProductRepositoryImpl productRepositoryImpl;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _hasSyncedOnStart = false;

  final getIt = GetIt.instance;
  Timer? _pollingTimer;

  SyncManager(
      {required this.connectivity,
      required this.userRepositoryImpl,
      required this.productRepositoryImpl});

  void start() {
    _connectivitySubscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        Future.delayed(Duration(seconds: 4), () async {
          if (!_hasSyncedOnStart) {
            _hasSyncedOnStart = true;
            _updateAllData();
          }
        });
      }
    });

    _pollingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _updateAllData();
    });
  }

  void syncOnAppStart() async {
    var results = await connectivity.checkConnectivity();
    if (results.isNotEmpty && results.first != ConnectivityResult.none) {
      if (!_hasSyncedOnStart) {
        _hasSyncedOnStart = true;
        _updateAllData();
      }
    }
  }

  void stop() {
    _pollingTimer?.cancel();
    _connectivitySubscription?.cancel();
  }

  void _updateAllData() async {
    bool newUpdateUsers = await userRepositoryImpl.updateAllUsersRemoteSide();
    bool newUpdateProducts =
        await productRepositoryImpl.updateAllProductsRemoteSide();

    if (newUpdateUsers) getIt<UsersBloc>().add(RefreshUsersEvent());

    if (newUpdateProducts) {
      final productsBloc = getIt<ProductsBloc>();
      if (productsBloc.currentUserId != null) {
        productsBloc
            .add(RefreshProductsEvent(userId: productsBloc.currentUserId!));
      }
    }
  }
}
