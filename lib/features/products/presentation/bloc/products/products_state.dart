part of 'products_bloc.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

final class ProductsInitial extends ProductsState {}

class LoadingProductsState extends ProductsState {}

class LoadedProductsState extends ProductsState {
  final List<Product> products;
  final int total;

  const LoadedProductsState({required this.products, required this.total});

  @override
  List<Object> get props => [products, total];
}

class ErrorProductsState extends ProductsState {
  final String message;

  const ErrorProductsState({required this.message});

  @override
  List<Object> get props => [message];
}

class DoneProductsState extends ProductsState {
  final String message;

  const DoneProductsState({required this.message});

  @override
  List<Object> get props => [message];
}
