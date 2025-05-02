import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts(int userId);

  Future<Either<Failure, Unit>> addProduct(Product product);

  Future<Either<Failure, Unit>> updateProduct(Product product);

  Future<Either<Failure, Unit>> deleteProduct(int id);

  Future<Either<Failure, int>> getTotalUnPaid(int userId);
}
