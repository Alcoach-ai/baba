import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/presentaion/utils/add_edit_alert_dialog.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:baba_bloc/features/products/presentation/pages/products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;

class UsersListWidget extends StatelessWidget {
  final List<User> users;
  const UsersListWidget({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              context
                  .read<ProductsBloc>()
                  .add(GetAllProductsEvent(userId: users[index].id!));
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ProductsPage(user: users[index]);
              }));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 2,
                          children: [
                            Container(
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.blue.shade800,
                              ),
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AddEditAlertDialog(
                                            isUpdate: true,
                                            user: users[index],
                                          ));
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.green.shade400,
                                ),
                              ),
                            ),
                            // Container(
                            //   width: 50,
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(16),
                            //     color: Colors.blue.shade800,
                            //   ),
                            //   alignment: Alignment.center,
                            //   child: TextButton(
                            //     onPressed: () {
                            //       showDialog(
                            //           context: context,
                            //           builder: (context) => AddEditAlertDialog(
                            //                 isUpdate: true,
                            //                 user: users[index],
                            //               ));
                            //     },
                            //     child: Icon(
                            //       Icons.delete,
                            //       color: Colors.red.shade400,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              users[index].name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                            )),
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.grey)
              ],
            ),
          ),
        );
      },
    );
  }
}
