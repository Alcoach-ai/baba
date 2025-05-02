import 'package:baba_bloc/core/widgets/loading_widget.dart';
import 'package:baba_bloc/core/widgets/main_app_bar.dart';
import 'package:baba_bloc/features/customers/presentaion/bloc/users/users_bloc.dart';
import 'package:baba_bloc/features/customers/presentaion/utils/add_edit_alert_dialog.dart';
import 'package:baba_bloc/core/widgets/MessageWidget.dart';
import 'package:baba_bloc/features/customers/presentaion/widgets/users_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchFormController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // drawer: NavDrawer(context),
        appBar: MainAppBar(appBar: AppBar(), title: 'بحبك بابا'),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton());
  }

  Widget _buildBody() {
    return BlocConsumer<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is DoneUsersState) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is LoadingUsersSate) {
          return LoadingWidget();
        } else if (state is LoadedUsersState) {
          return RefreshIndicator(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _searchFormController,
                      decoration: const InputDecoration(
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: UsersListWidget(users: state.users),
                  ),
                ],
              ),
              onRefresh: () => _onRefresh(context));
        } else if (state is ErrorUsersState) {
          return MessageWidget(message: state.message);
        }
        return LoadingWidget();
      },
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AddEditAlertDialog(isUpdate: false));
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    BlocProvider.of<UsersBloc>(context).add(RefreshUsersEvent());
  }
}
