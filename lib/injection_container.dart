import 'package:baba_bloc/core/database/database_provider.dart';
import 'package:baba_bloc/core/network/network_info.dart';
import 'package:baba_bloc/core/network/network_info_impl.dart';
import 'package:baba_bloc/core/sync/sync_manager.dart';
import 'package:baba_bloc/features/customers/data/datasources/user_locale_data_source.dart';
import 'package:baba_bloc/features/customers/data/datasources/user_remote_data_source.dart';
import 'package:baba_bloc/features/customers/data/repository/user_repository_impl.dart';
import 'package:baba_bloc/features/customers/domain/repository/user_repository.dart';
import 'package:baba_bloc/features/customers/domain/usecases/add_user_use_case.dart';
import 'package:baba_bloc/features/customers/domain/usecases/delete_user_use_case.dart';
import 'package:baba_bloc/features/customers/domain/usecases/get_all_users_usecase.dart';
import 'package:baba_bloc/features/customers/domain/usecases/update_user_use_case.dart';
import 'package:baba_bloc/features/customers/presentaion/bloc/users/users_bloc.dart';
import 'package:baba_bloc/features/products/data/datasource/product_locale_data_source.dart';
import 'package:baba_bloc/features/products/data/datasource/product_remote_data_source.dart';
import 'package:baba_bloc/features/products/domain/respository/product_repository.dart';
import 'package:baba_bloc/features/products/data/repository/product_repository_impl.dart';
import 'package:baba_bloc/features/products/domain/usecases/add_product_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/delete_product_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/get_all_products_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/get_total_un_paid_use_case.dart';
import 'package:baba_bloc/features/products/domain/usecases/update_product_use_case.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Futures . Posts

  // Bloc
  sl.registerLazySingleton(() => UsersBloc(
      getUsersUseCase: sl(),
      addUserUseCase: sl(),
      deleteUserUseCase: sl(),
      updateUserUseCase: sl()));

  sl.registerLazySingleton(() => ProductsBloc(
      addProductUseCase: sl(),
      deleteProductUseCase: sl(),
      getAllProductsUseCase: sl(),
      getTotalUnPaidUseCase: sl(),
      updateProductUseCase: sl()));

  //sl.registerLazySingleton<UsersBloc>(() => UsersBloc(sl()));

  // Usecases
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => AddUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));

  sl.registerLazySingleton(() => GetAllProductsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalUnPaidUseCase(sl()));

  // Repository

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
      userLocaleDataSource: sl(),
      userRemoteDataSource: sl(),
      networkInfo: sl()));

  sl.registerLazySingleton<UserRepositoryImpl>(
      () => sl<UserRepository>() as UserRepositoryImpl);

  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
      productLocaleDataSource: sl(), productRemoteDataSource: sl()));

  sl.registerLazySingleton<ProductRepositoryImpl>(
      () => sl<ProductRepository>() as ProductRepositoryImpl);

  // Datasources

  sl.registerLazySingleton<UserLocaleDataSource>(
      () => UserLocaleDataSourceImpl(databaseProvider: sl()));

  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl());

  sl.registerLazySingleton<ProductLocaleDataSource>(
      () => ProductLocaleDataSourceImpl(databaseProvider: sl()));

  sl.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(databaseProvider: sl()));

  // Core
  sl.registerLazySingleton(() => DatabaseProvider.instance);

  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectivity: sl()));

  sl.registerLazySingleton(() => SyncManager(
      connectivity: sl(),
      userRepositoryImpl: sl(),
      productRepositoryImpl: sl()));

  //External
}
