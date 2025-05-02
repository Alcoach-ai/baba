import 'package:baba_bloc/features/customers/domain/entities/User.dart';
import 'package:baba_bloc/features/customers/presentaion/bloc/users/users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditAlertDialog extends StatefulWidget {
  final bool isUpdate;
  final User? user;

  const AddEditAlertDialog({super.key, required this.isUpdate, this.user});

  @override
  State<AddEditAlertDialog> createState() => _AddEditAlertDialogState();
}

class _AddEditAlertDialogState extends State<AddEditAlertDialog> {
  final TextEditingController addUserNameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    addUserNameController.text = (widget.user != null) ? widget.user!.name : '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 5,
        child: Form(
          key: formKey,
          child: Column(children: [
            Text(
              (!widget.isUpdate) ? 'اضافة زبون' : 'تعديل زبون',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                controller: addUserNameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  border: UnderlineInputBorder(),
                  labelText: 'اسم الزبون',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: InkWell(
                onTap: () {
                  bool isValidate = formKey.currentState!.validate();
                  if (isValidate) {
                    String status = "1";
                    final user = User(
                        id: (widget.isUpdate) ? widget.user!.id : null,
                        name: addUserNameController.text,
                        status: status,
                        lastupdate: DateTime.now().toUtc().toIso8601String());
                    BlocProvider.of<UsersBloc>(context).add((widget.isUpdate)
                        ? UpdateUserEvent(user: user)
                        : AddUserEvent(user: user));
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 4,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blue,
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: const Center(
                      child: Text(
                    'حفظ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      fontSize: 20,
                    ),
                  )),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
