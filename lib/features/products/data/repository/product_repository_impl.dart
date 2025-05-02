import 'package:baba_bloc/core/error/exceptions.dart';
import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/data/datasource/product_locale_data_source.dart';
import 'package:baba_bloc/features/products/data/datasource/product_remote_data_source.dart';
import 'package:baba_bloc/features/products/data/models/product_model.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/domain/respository/product_repository.dart';
import 'package:dartz/dartz.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocaleDataSource productLocaleDataSource;
  final ProductRemoteDataSource productRemoteDataSource;

  ProductRepositoryImpl(
      {required this.productLocaleDataSource,
      required this.productRemoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getAllProducts(int userId) async {
    try {
      final localeProducts =
          await productLocaleDataSource.getAllProducts(userId);

      return Right(localeProducts);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addProduct(Product product) async {
    final ProductModel userModel = ProductModel(
        name: product.name,
        date: product.date,
        price: product.price,
        type: product.type,
        weight: product.weight,
        user_id: product.user_id);
    return await _sendRequest(() {
      return productLocaleDataSource.addProduct(userModel);
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) async {
    return await _sendRequest(() {
      return productLocaleDataSource.deleteProduct(id);
    });
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) async {
    final ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        date: product.date,
        price: product.price,
        type: product.type,
        weight: product.weight,
        user_id: product.user_id);
    return await _sendRequest(() {
      return productLocaleDataSource.updateProduct(productModel);
    });
  }

  @override
  Future<Either<Failure, int>> getTotalUnPaid(int userId) async {
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
}
