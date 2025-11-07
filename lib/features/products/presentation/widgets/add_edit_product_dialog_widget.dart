import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditProductDialogWidget extends StatefulWidget {
  final String? userId;
  final bool isUpdate;
  final Product? product;
  const AddEditProductDialogWidget(
      {super.key, this.userId, required this.isUpdate, this.product});

  @override
  State<AddEditProductDialogWidget> createState() =>
      _AddEditProductDialogWidgetState();
}

class _AddEditProductDialogWidgetState
    extends State<AddEditProductDialogWidget> {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  String priceSign = "+";
  bool s = true;
  final GlobalKey<FormState> _form1Key = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      idController.text = widget.product!.id.toString();
      nameController.text = widget.product!.name.toString();
      typeController.text = widget.product!.type.toString();
      weightController.text = widget.product!.weight.toString();
      priceController.text = widget.product!.price.toString();
      dateController.text = widget.product!.date.toString();
    }
  }

  String getCurrentDateTimeString() {
    final now = DateTime.now();
    final formatted =
        "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: MediaQuery.of(context).size.height * 3 / 7,
        child: Form(
          key: _form1Key,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              child: TextFormField(
                controller: nameController,
                // validator: (value) {
                //   if (value!.isEmpty) return "لا يمكنك تركه فارغا";
                // },
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  border: UnderlineInputBorder(),
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('اسم القطعة'),
                  ),
                ),
              ),
            ),
            Container(
              child: TextFormField(
                textDirection: TextDirection.rtl,
                controller: weightController,
                // validator: (value) {
                //   if (value!.isEmpty) return "لا يمكنك تركه فارغا";
                // },

                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('الوزن'),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 200,
                  child: TextFormField(
                    textDirection: TextDirection.ltr,
                    keyboardType: TextInputType.numberWithOptions(),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.deny(RegExp(r'[^\d{10}$]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "لا يمكنك تركه فارغا";
                      }
                      if (value.startsWith('0')) {
                        return "لا يمكن أن يبدأ الرقم بصفر";
                      }
                      return null;
                    },
                    controller: priceController,
                    decoration: const InputDecoration(
                      label: const Align(
                        alignment: Alignment.centerRight,
                        child: Text('السعر'),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: (s) ? Colors.blue : Colors.red),
                  ),
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        s = !s;
                      });
                    },
                    child: (s)
                        ? Text(
                            "+",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          )
                        : Text(
                            "-",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: InkWell(
                onTap: () {
                  if (_form1Key.currentState!.validate()) {
                    String status = '1';
                    Product product = Product(
                        id: (widget.isUpdate) ? idController.text : null,
                        name: nameController.text,
                        type: typeController.text,
                        weight: weightController.text,
                        price: (s)
                            ? priceController.text
                            : (int.parse(priceController.text) * -1).toString(),
                        date: DateTime.now().toString(),
                        user_id: (widget.isUpdate)
                            ? widget.product!.user_id
                            : widget.userId,
                        status: status,
                        lastupdate: DateTime.now().toUtc().toIso8601String());
                    BlocProvider.of<ProductsBloc>(context).add((widget.isUpdate)
                        ? UpdateProductEvent(product: product)
                        : AddProductEvent(product: product));
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
                  child: Center(
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
