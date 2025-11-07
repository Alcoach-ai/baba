import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/presentaion/bloc/users/users_bloc.dart';
import 'package:baba_bloc/features/customers/presentaion/utils/add_edit_alert_dialog.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:baba_bloc/features/products/presentation/pages/products_page.dart';
import 'package:emoji_alert/arrays.dart';
import 'package:emoji_alert/emoji_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;

class UsersListWidget extends StatelessWidget {
  final List<User> users;

  const UsersListWidget({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final total = users[index].total ?? 0.0;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              context
                  .read<ProductsBloc>()
                  .add(GetAllProductsEvent(userId: user.id!));
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ProductsPage(user: user);
              }));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  // height: 30,
                  child: Container(
                    padding: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade100),
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffDFEAFE),
                      boxShadow: [
                        BoxShadow(
                          color: (total == 0.0)
                              ? Colors.grey.shade300
                              : Color(0xffDFEAFE),

                          blurRadius: 6,
                          offset: Offset(3, 2), // Shadow position
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              (total != 0.0)
                                  ? Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AddEditAlertDialog(
                                              isUpdate: true,
                                              user: user,
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  //const SizedBox(width: 6),
                                  : Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        onPressed: () async {
                                          final usersBloc =
                                              context.read<UsersBloc>();
                                          await showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text(
                                                "بابااااا انتبه",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red),
                                              ),
                                              content: const Text(
                                                "لا تحذف وتجي تسب عليي... انا مادخلي عذر من انذر يا بابا",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, false);
                                                  },
                                                  child: const Text('إلغاء'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    EmojiAlert(
                                                      description: Column(
                                                        children: [
                                                          Text(
                                                            "أبو بديع صلي عالنبي",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                          SizedBox(height: 15),
                                                          Directionality(
                                                              textDirection:
                                                                  TextDirection
                                                                      .rtl,
                                                              child: Text(
                                                                "هي صفحة الزبون كاملة ... اذا راحت مارح رجعلك اياها هه",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            height: 25,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context,
                                                                      false);
                                                                  Navigator.pop(
                                                                      context,
                                                                      false);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 80,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .green
                                                                        .withOpacity(
                                                                            0.2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "بلاها",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                  )),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  usersBloc.add(
                                                                      DeleteUserEvent(
                                                                          userId:
                                                                              user.id!));
                                                                  Navigator.pop(
                                                                      context,
                                                                      false);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 80,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .red
                                                                        .withOpacity(
                                                                            0.2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "متأكد",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                  )),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      //  Text("", style: TextStyle(fontWeight: FontWeight.bold,)),
                                                      emojiType:
                                                          EMOJI_TYPE.SHOCKED,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              2,
                                                    ).displayAlert(context);
                                                  },
                                                  child: const Text('حذف'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              total.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: SizedBox(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
