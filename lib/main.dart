import 'package:baba_bloc/core/database/database_provider.dart';
import 'package:baba_bloc/core/helpers/my_bloc_opserver.dart';
import 'package:baba_bloc/core/sync/sync_manager.dart';
import 'package:baba_bloc/features/customers/data/repository/user_repository_impl.dart';
import 'package:baba_bloc/features/customers/presentaion/bloc/users/users_bloc.dart';
import 'package:baba_bloc/features/customers/presentaion/pages/users_page.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DatabaseProvider.instance.initDatabase();
  await di.init();

  final syncManager = SyncManager(
    connectivity: di.sl<Connectivity>(),
    userRepositoryImpl: di.sl<UserRepositoryImpl>(),
  );

  syncManager.syncOnAppStart(); // Try sync once when app starts
  syncManager.start();

  Bloc.observer = MyBlocObserver();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(
        create: (context) => di.sl<UsersBloc>()..add(GetAllUsersEvent())),
    BlocProvider(create: (context) => di.sl<ProductsBloc>()),
  ], child: MaterialApp(debugShowCheckedModeBanner: false, home: myApp())));
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UsersPage();
  }
}
