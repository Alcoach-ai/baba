import 'package:baba_bloc/core/error/failure.dart';
import 'package:baba_bloc/core/strings/failure.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/domain/usecases/add_product_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/delete_product_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/get_all_products_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/get_total_un_paid_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/update_product_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetAllProductsUseCase getAllProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final GetTotalUnPaidUseCase getTotalUnPaidUseCase;

  ProductsBloc(
      {required this.getAllProductsUseCase,
      required this.addProductUseCase,
      required this.updateProductUseCase,
      required this.deleteProductUseCase,
      required this.getTotalUnPaidUseCase})
      : super(ProductsInitial()) {
    on<ProductsEvent>((event, emit) async {
      if (event is GetAllProductsEvent) {
        loadUsers(event.userId);
      } else if (event is RefreshProductsEvent) {
        loadUsers(event.userId);
      } else if (event is AddProductEvent) {
        emit(LoadingProductsState());
        final productsOrFailure = await addProductUseCase(event.product);
        emit(_eitherDoneOrErrorState(productsOrFailure, "Added"));
        loadUsers(event.product.user_id);
      } else if (event is UpdateProductEvent) {
        emit(LoadingProductsState());
        final productsOrFailure = await updateProductUseCase(event.product);
        emit(_eitherDoneOrErrorState(productsOrFailure, "Updated"));
        loadUsers(event.product.user_id);
      } else if (event is DeleteProductEvent) {
        emit(LoadingProductsState());
        final doneOrFailure = await deleteProductUseCase(event.productId);
        emit(_eitherDoneOrErrorState(doneOrFailure, "Deleted"));
        loadUsers(event.user_id);
      }
    });
  }

  Future<void> loadUsers(int? id) async {
    emit(LoadingProductsState());
    final productsOrFailure = await getAllProductsUseCase(id!);
    final totalOrFailure = await getTotalUnPaidUseCase(id);
    totalOrFailure.fold((failure) {
      emit(ErrorProductsState(message: _convertFailureToMessage(failure)));
    }, (total) {
      productsOrFailure.fold((failure) {
        emit(ErrorProductsState(message: _convertFailureToMessage(failure)));
      }, (products) {
        emit(LoadedProductsState(products: products, total: total));
      });
    });
  }

  ProductsState _eitherDoneOrErrorState(
      Either<Failure, Unit> either, String messgae) {
    return either.fold((failure) {
      return ErrorProductsState(message: _convertFailureToMessage(failure));
    }, (_) {
      return DoneProductsState(message: messgae);
    });
  }

  String _convertFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Please Try Again';
    }
  }
}
