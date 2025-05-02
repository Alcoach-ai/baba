import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/features/products/domain/respository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetTotalUnPaidUseCase {
  final ProductRepository productRepository;

  GetTotalUnPaidUseCase(this.productRepository);

  Future<Either<Failure, int>> call(int userId) async {
    return await productRepository.getTotalUnPaid(userId);
  }
}
