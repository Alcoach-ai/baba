import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:baba_bloc/features/products/presentation/widgets/add_edit_product_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsListWidget extends StatelessWidget {
  final List<Product> products;
  final int total;
  const ProductsListWidget(
      {super.key, required this.products, required this.total});

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();

    String formate =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

    return ListView.builder(
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  showUpdateDeleteDialog(context, products[index]);
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                formate,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[400]),
                              ),
                              Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    'السعر: ${products[index].price}',
                                    style: TextStyle(fontSize: 16),
                                  )),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    products[index].name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    'الوزن: ${products[index].weight}',
                                    style: TextStyle(fontSize: 16),
                                  )),
                            ],
                          ),
                        ]),
                  ),
                ),
              ),
              Divider(color: Colors.grey)
            ],
          ),
        );
      },
    );
  }

  Future showUpdateDeleteDialog(BuildContext context, Product product) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Center(
                  child: Column(
                children: [
                  Text(
                    "بابااااا انتبه",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        "لا تحذف وتجي تسب عليي... انا مادخلي عذر من انذر يا بابا",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          context.read<ProductsBloc>().add(DeleteProductEvent(
                              productId: product.id!,
                              user_id: product.user_id!));
                        },
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(child: Text("حذف")),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => AddEditProductDialogWidget(
                                    isUpdate: true,
                                    product: product,
                                    userId: null,
                                  ));
                        },
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(child: Text("تعديل")),
                        ),
                      )
                    ],
                  )
                ],
              )),
            ));
  }
}
