import 'package:baba_bloc/core/helpers/route_observer.dart';
import 'package:baba_bloc/core/widgets/loading_widget.dart';
import 'package:baba_bloc/core/widgets/main_app_bar.dart';
import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/presentaion/bloc/users/users_bloc.dart';
import 'package:baba_bloc/features/customers/presentaion/utils/add_edit_alert_dialog.dart';
import 'package:baba_bloc/core/widgets/MessageWidget.dart';
import 'package:baba_bloc/features/customers/presentaion/widgets/users_list_widget.dart';
import 'package:baba_bloc/features/products/domain/usecases/get_total_un_paid_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import 'package:baba_bloc/main.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> with RouteAware {
  final TextEditingController _searchFormController = TextEditingController();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  Map<String, int> _userTotals = {};

  bool _sortByNameAsc = true;
  bool _sortByTotalAsc = true;
  bool _sortByDateAsc = true;

  String _lastSort = 'date';

  @override
  void initState() {
    super.initState();
    _onRefresh(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when coming back to this page
    context.read<UsersBloc>().add(RefreshUsersEvent());
  }

  @override
  void dispose() {
    _searchFormController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _sortByName({bool toggle = true}) {
    if (toggle) _sortByNameAsc = !_sortByNameAsc;
    _filteredUsers.sort((a, b) =>
        _sortByNameAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    _lastSort = 'name';
  }

  void _sortByNameAndUpdate() {
    setState(() {
      _sortByName();
    });
  }

  void _sortByTotal({bool toggle = true}) {
    if (toggle) _sortByTotalAsc = !_sortByTotalAsc;
    _filteredUsers.sort((a, b) {
      int totalA = _userTotals[a.id] ?? 0;
      int totalB = _userTotals[b.id] ?? 0;
      return _sortByTotalAsc
          ? totalA.compareTo(totalB)
          : totalB.compareTo(totalA);
    });
    _lastSort = 'total';
  }

  void _sortByTotalAndUpdate() {
    setState(() {
      _sortByTotal();
    });
  }

// Optional: If you have createdAt date
  void _sortByDate({bool toggle = true}) {
    if (toggle) _sortByDateAsc = !_sortByDateAsc;

    _filteredUsers.sort((a, b) {
      final dateA = (a.lastupdate != null && a.lastupdate!.isNotEmpty)
          ? DateTime.parse(a.lastupdate!)
          : DateTime.fromMillisecondsSinceEpoch(0);

      final dateB = (b.lastupdate != null && b.lastupdate!.isNotEmpty)
          ? DateTime.parse(b.lastupdate!)
          : DateTime.fromMillisecondsSinceEpoch(0);

      return _sortByDateAsc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    _lastSort = 'date';
  }

  void _sortByDateAndUpdate() {
    setState(() {
      _sortByDate();
    });
  }
  // void _filterUsers(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       _filteredUsers = List.from(_allUsers);
  //     } else {
  //       final lower = query.toLowerCase();
  //       _filteredUsers = _allUsers.where((user) {
  //         return user.name.toLowerCase().contains(lower);
  //       }).toList();
  //     }
  //   });
  // }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        final lower = query.toLowerCase();
        _filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(lower);
        }).toList();
      }

      // Apply the same sort that was active before filtering
      if (!_sortByNameAsc && !_sortByTotalAsc && !_sortByDateAsc) {
        // No sort selected yet
      } else {
        // Reapply whichever sort was last used
        if (_lastSort == 'name') _sortByName();
        if (_lastSort == 'total') _sortByTotal();
        if (_lastSort == 'date') _sortByDate();
      }
    });
  }

  Future<void> loadTotals() async {
    if (!mounted) return;
    final useCase = di.sl<GetTotalUnPaidUseCase>();
    final totals = <String, int>{};

    for (final user in _allUsers.toList()) {
      if (!mounted) return;

      int amount = await useCase(user.id!).then(
        (either) => either.fold((failure) => 0, (value) => value),
      );
      totals[user.id!] = amount;
    }

    if (!mounted) return;

    setState(() {
      _userTotals = totals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        appBar: AppBar(),
        title: 'بحبك بابا',
        showAddEdit: () => showAddDeleteDialog(),
        isHome: true,
      ),
      body: _buildBody(),
      // floatingActionButton: _buildFloatingActionButton()
    );
  }

  Widget _buildBody() {
    return BlocConsumer<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is DoneUsersState) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          _onRefresh(context);
        }
      },
      builder: (context, state) {
        if (state is LoadingUsersSate) {
          return LoadingWidget();
        } else if (state is LoadedUsersState) {
          _filteredUsers = List.from(state.users);

          // _filteredUsers = state.users;

          // if (_allUsers != state.users) {
          //   _allUsers = state.users;
          //   if (_searchFormController.text.isEmpty) {
          //     _filteredUsers = state.users;
          //   } else {
          //     _filterUsers(_searchFormController.text);
          //   }
          // }

          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   loadTotals();
          // });

          return RefreshIndicator(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      textDirection: TextDirection.rtl,
                      controller: _searchFormController,
                      onChanged: (value) {
                        context
                            .read<UsersBloc>()
                            .add(SearchUsersEvent(_searchFormController.text));
                      },
                      decoration: const InputDecoration(
                        labelText: "بحث",
                        hintText: "ابحث باسم المستخدم",
                        hintTextDirection: TextDirection.rtl,
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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Action column
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    context.read<UsersBloc>().add(
                                        SortUsersEvent(
                                            SortField.lastUpdate,
                                            (_sortByDateAsc)
                                                ? SortOrder.ascending
                                                : SortOrder.descending));
                                    _sortByDateAsc = !_sortByDateAsc;
                                    _lastSort = "date";
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      _sortByDateAsc
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      size: 16,
                                      color: (_lastSort == "date")
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                    Text('التاريخ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: (_lastSort == "date")
                                              ? Colors.blue
                                              : Colors.black,
                                        )),
                                  ],
                                ),
                              ),
                              // Total column
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    context.read<UsersBloc>().add(
                                        SortUsersEvent(
                                            SortField.total,
                                            (_sortByTotalAsc)
                                                ? SortOrder.ascending
                                                : SortOrder.descending));
                                    _sortByTotalAsc = !_sortByTotalAsc;
                                    _lastSort = "total";
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      _sortByTotalAsc
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      size: 16,
                                      color: (_lastSort == "total")
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                    Text('المبلغ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: (_lastSort == "total")
                                              ? Colors.blue
                                              : Colors.black,
                                        )),
                                  ],
                                ),
                              ),
                              // Name column
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    context.read<UsersBloc>().add(
                                        SortUsersEvent(
                                            SortField.name,
                                            (_sortByNameAsc)
                                                ? SortOrder.ascending
                                                : SortOrder.descending));
                                    _sortByNameAsc = !_sortByNameAsc;
                                    _lastSort = "name";
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      _sortByNameAsc
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      size: 16,
                                      color: (_lastSort == "name")
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                    Text('الاسم',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: (_lastSort == "name")
                                              ? Colors.blue
                                              : Colors.black,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: UsersListWidget(
                            users: _filteredUsers,
                          ),
                        ),
                      ],
                    ),
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
          builder: (context) => AddEditAlertDialog(isUpdate: false),
        ).then((_) => _onRefresh(context));
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    );
  }

  void showAddDeleteDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddEditAlertDialog(isUpdate: false),
    ).then((_) => _onRefresh(context));
  }

  Future<void> _onRefresh(BuildContext context) async {
    _searchFormController.clear();
    _allUsers.clear();
    context.read<UsersBloc>().add(GetAllUsersEvent());
  }
}
