import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/domain/respository/product_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteProductUseCase {
  final ProductRepository productRepository;

  DeleteProductUseCase(this.productRepository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await productRepository.deleteProduct(userId, true);
  }
}
