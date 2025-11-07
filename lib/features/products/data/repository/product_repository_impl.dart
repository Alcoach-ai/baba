import 'dart:async';

import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/data/datasource/product_locale_data_source.dart';
import 'package:baba_bloc/features/products/data/datasource/product_remote_data_source.dart';
import 'package:baba_bloc/features/products/data/models/product_model.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/domain/respository/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocaleDataSource productLocaleDataSource;
  final ProductRemoteDataSource productRemoteDataSource;

  ProductRepositoryImpl(
      {required this.productLocaleDataSource,
      required this.productRemoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getAllProducts(String id) async {
    try {
      final localeProducts = await productLocaleDataSource.getAllProducts(id);
      localeProducts.forEach((item) {});
      final filteredProducts = localeProducts.where((product) {
        return product.status != '2' && product.status != '3';
      }).toList();
      filteredProducts.sort((a, b) {
      final dateA = DateTime.tryParse(a.date) ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.date) ?? DateTime(1970);
      return dateB.compareTo(dateA); // Descending (newest first)
    });
      return Right(filteredProducts);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addProduct(
      Product product, bool isAddRemote) async {
    final uuid = Uuid();
    final ProductModel userModel = ProductModel(
        id: (!isAddRemote) ? product.id : uuid.v4(),
        name: product.name,
        date: product.date,
        price: product.price,
        type: product.type,
        weight: product.weight,
        user_id: product.user_id,
        status: product.status,
        lastupdate: product.lastupdate);

    final response = await _sendRequest(() {
      return productLocaleDataSource.addProduct(userModel);
    });

    if (isAddRemote) unawaited(_syncAddProductWithGoogleSheet(userModel));
    return response;
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(
      String id, bool isDeleteRemote) async {
    String date = DateTime.now().toUtc().toIso8601String();
    final response = await _sendRequest(() {
      return productLocaleDataSource.deleteProduct(id, date);
    });

    if (isDeleteRemote) unawaited(_syncDeleteProductWithGoogleSheet(id, date));

    return response;
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(
      Product product, bool isUpdateRemote) async {
    final ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        date: product.date,
        price: product.price,
        type: product.type,
        weight: product.weight,
        user_id: product.user_id,
        status: product.status,
        lastupdate: product.lastupdate);

    final response = _sendRequest(() {
      return productLocaleDataSource.updateProduct(productModel);
    });
    if (isUpdateRemote) unawaited(_syncUpdateProductWithGoogleSheet(product));

    return response;
  }

  @override
  Future<Either<Failure, int>> getTotalUnPaid(String userId) async {
    try {
      int totalUnPaid = await productLocaleDataSource.getTotalUnPaid(userId);

      return Right(totalUnPaid);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Unit>> _sendRequest(
      Future<Unit> Function() addUpdateDeleteProduct) async {
    try {
      await addUpdateDeleteProduct();
      return Right(unit);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  void updateProductRemoteSide(ProductModel product) async {
    try {
      int result = await productRemoteDataSource.updateProduct(product);

      if (result == 1) {
        if (product.status == '2') {
          await productLocaleDataSource.markProductSynced(product.id!, '3');
        } else
          await productLocaleDataSource.markProductSynced(product.id!, '0');
      }
    } on CacheException {
      if (kDebugMode) {
        print("Cache Exception");
      }
    }
  }

  void addProductRemoteSide(ProductModel product) async {
    try {
      int result = await productRemoteDataSource.addProduct(product);

      if (result == 1) {
        if (product.status == '2') {
          await productLocaleDataSource.markProductSynced(product.id!, '3');
        } else
          await productLocaleDataSource.markProductSynced(product.id!, '0');
      }
    } on CacheException {
      if (kDebugMode) {
        print("Cache Exception");
      }
    }
  }

  void deleteProductRemoteSide(String id, String date) async {
    try {
      int result = await productRemoteDataSource.deleteProduct(id, date);

      if (result == 1) {
        await productLocaleDataSource.markProductSynced(id, '3');
      }
    } on CacheException {
      if (kDebugMode) {
        print("Cache Exception");
      }
    }
  }

  // void updateAllProductsRemoteSide() async {
  //   try {
  //     final localeNonSyncedProducts =
  //         await productLocaleDataSource.getNonSyncedProducts();

  //     final remoteAllSyncedProducts =
  //         await productRemoteDataSource.getAllProducts();

  //     final remoteProductsMap = {
  //       for (var item in remoteAllSyncedProducts) item.id: item
  //     };

  //     // compare lastupdate
  //     for (var localeproduct in localeNonSyncedProducts) {
  //       final remoteProduct = remoteProductsMap[localeproduct.id!];
  //       if (remoteProduct != null) {
  //         final localeTime = DateTime.parse(localeproduct.lastupdate);
  //         final remoteTime = DateTime.parse(remoteProduct.lastupdate);
  //         if (localeTime.isAfter(remoteTime)) {
  //           updateProductRemoteSide(localeproduct);
  //         } else if (remoteTime.isAfter(localeTime)) {
  //           await updateProduct(remoteProduct, false);
  //         } else {
  //           if (kDebugMode) {
  //             print("user is up tp date ${localeproduct.name}");
  //           }
  //         }
  //       } else {
  //         addProductRemoteSide(localeproduct);
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }

  Future<bool> updateAllProductsRemoteSide() async {
    bool newUpdateHappened = false;
    try {
      final localeProducts =
          await productLocaleDataSource.getAllProductsToSync();

      final remoteProducts = await productRemoteDataSource.getAllProducts();

      // Create maps for fast lookup
      final remoteMap = {
        for (var product in remoteProducts) product.id: product
      };

      final localMap = {
        for (var product in localeProducts) product.id: product
      };

      // 1. Sync from remote to local
      for (var remoteProduct in remoteProducts) {
        print(remoteProduct);
        final localProduct = localMap[remoteProduct.id];

        // Safely parse date
        final remoteTime =
            DateTime.tryParse(remoteProduct.lastupdate.toString()) ??
                DateTime.now();

        final localTime = localProduct != null
            ? DateTime.tryParse(localProduct.lastupdate.toString()) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0);

        if (localProduct == null) {
          await addProduct(remoteProduct, false); // add to local
          newUpdateHappened = true;
        } else if (remoteTime.isAfter(localTime)) {
          await updateProduct(remoteProduct, false); // update local
          newUpdateHappened = true;
        } else if (localTime.isAfter(remoteTime)) {
          updateProductRemoteSide(localProduct); // update remote
        } else {
          print("Up to date: ${localProduct.name} ${localProduct.lastupdate}");
        }
      }

      // 2. Sync from local to remote (new users not on server)
      for (var localProduct in localeProducts) {
        final remoteProduct = remoteMap[localProduct.id];
        if (remoteProduct == null) {
          print(
              "Remote Product not found, adding: ${localProduct.name} ${localProduct.lastupdate}");
          addProductRemoteSide(localProduct); // add to remote
        }
      }
    } catch (e) {
      print("Sync Product error: $e");
    }
    return newUpdateHappened;
  }

  Future<void> _syncAddProductWithGoogleSheet(ProductModel productModel) async {
    //ProductModel productModel = await productLocaleDataSource.getProduct();

    addProductRemoteSide(productModel);
  }

  Future<void> _syncDeleteProductWithGoogleSheet(String id, String date) async {
    deleteProductRemoteSide(id, date);
  }

  Future<void> _syncUpdateProductWithGoogleSheet(Product product) async {
    try {
      int result = await productRemoteDataSource.updateProduct(ProductModel(
          id: product.id,
          name: product.name,
          type: product.type,
          weight: product.weight,
          price: product.price,
          date: product.date,
          user_id: product.user_id,
          status: product.status,
          lastupdate: product.lastupdate));

      if (result == 1) {
        ProductModel SyncedUserModel = ProductModel(
            id: product.id,
            name: product.name,
            type: product.type,
            weight: product.weight,
            price: product.price,
            date: product.date,
            user_id: product.user_id,
            status: "0",
            lastupdate: product.lastupdate);
        await productLocaleDataSource.updateProduct(SyncedUserModel);
      }
    } catch (e) {
      if (kDebugMode) {
        print("_syncUpdateProductWithGoogleSheet");
        print(e);
      }
    }
  }
}
