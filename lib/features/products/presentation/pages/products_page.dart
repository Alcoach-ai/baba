import 'package:baba_bloc/core/widgets/MessageWidget.dart';
import 'package:baba_bloc/core/widgets/loading_widget.dart';
import 'package:baba_bloc/core/widgets/main_app_bar.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:baba_bloc/features/products/presentation/widgets/add_edit_product_dialog_widget.dart';
import 'package:baba_bloc/features/products/presentation/widgets/products_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsPage extends StatefulWidget {
  final User user;
  const ProductsPage({super.key, required this.user});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state is DoneProductsState) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: MainAppBar(
              appBar: AppBar(),
              title: (state is LoadedProductsState)
                  ? state.total.toString()
                  : widget.user.name,
            ),
            body: _buildBody(context, state),
            floatingActionButton: _buildFloatingActionButton());
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    if (state is LoadingProductsState) {
      return LoadingWidget();
    } else if (state is LoadedProductsState) {
      return RefreshIndicator(
          child:
              ProductsListWidget(products: state.products, total: state.total),
          onRefresh: () => _onRefresh(context));
    } else if (state is ErrorProductsState) {
      return MessageWidget(message: state.message);
    }
    return LoadingWidget();
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AddEditProductDialogWidget(
              isUpdate: false, userId: widget.user.id),
        );
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    BlocProvider.of<ProductsBloc>(context)
        .add(RefreshProductsEvent(userId: widget.user.id!));
  }
}
