import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts(String id);

  Future<Either<Failure, Unit>> addProduct(Product product, bool isAddProduct);

  Future<Either<Failure, Unit>> updateProduct(
      Product product, bool isUpdateRemote);

  Future<Either<Failure, Unit>> deleteProduct(String id, bool isDeleteProduct);

  Future<Either<Failure, int>> getTotalUnPaid(String userId);
}
