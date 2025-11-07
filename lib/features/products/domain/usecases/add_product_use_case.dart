import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/domain/respository/product_repository.dart';
import 'package:dartz/dartz.dart';

class AddProductUseCase {
  final ProductRepository productRepository;

  AddProductUseCase(this.productRepository);

  Future<Either<Failure, Unit>> call(Product product) async {
    return await productRepository.addProduct(product, true);
  }
}
