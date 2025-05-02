import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/domain/respository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllProductsUseCase {
  final ProductRepository productRepository;

  GetAllProductsUseCase(this.productRepository);

  Future<Either<Failure, List<Product>>> call(int userId) async {
    return await productRepository.getAllProducts(userId);
  }
}
