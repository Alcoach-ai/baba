import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditProductDialogWidget extends StatefulWidget {
  final int? userId;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: MediaQuery.of(context).size.height / 3,
        child: Form(
          key: _form1Key,
          child: Column(children: [
            Container(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value!.isEmpty) return "Cannot be empty";
                  },
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    border: UnderlineInputBorder(),
                    labelText: 'اسم القطعة',
                  ),
                ),
              ),
            ),
            Container(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  controller: weightController,
                  validator: (value) {
                    if (value!.isEmpty) return "Cannot be empty";
                  },
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    border: UnderlineInputBorder(),
                    labelText: 'الوزن',
                  ),
                ),
              ),
            ),
            Container(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return "Cannot be empty";
                  },
                  controller: priceController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    border: UnderlineInputBorder(),
                    labelText: 'السعر',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: InkWell(
                onTap: () {
                  if (_form1Key.currentState!.validate()) {
                    Product product = Product(
                        id: (widget.isUpdate)
                            ? int.parse(idController.text)
                            : null,
                        name: nameController.text,
                        type: typeController.text,
                        weight: weightController.text,
                        price: priceController.text,
                        date: dateController.text,
                        user_id: (widget.isUpdate)
                            ? widget.product!.user_id
                            : widget.userId);
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
