part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class GetAllProductsEvent extends ProductsEvent {
  final int userId;

  const GetAllProductsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class RefreshProductsEvent extends ProductsEvent {
  final int userId;

  const RefreshProductsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class AddProductEvent extends ProductsEvent {
  final Product product;

  const AddProductEvent({required this.product});

  @override
  List<Object> get props => [product];
}

class DeleteProductEvent extends ProductsEvent {
  final int productId;
  final int user_id;

  const DeleteProductEvent({required this.productId, required this.user_id});

  @override
  List<Object> get props => [productId, user_id];
}

class UpdateProductEvent extends ProductsEvent {
  final Product product;

  const UpdateProductEvent({required this.product});

  @override
  List<Object> get props => [product];
}
