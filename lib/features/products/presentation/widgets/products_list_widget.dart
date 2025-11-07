import 'package:baba_bloc/features/products/domain/entities/Product.dart';
import 'package:baba_bloc/features/products/presentation/bloc/products/products_bloc.dart';
import 'package:baba_bloc/features/products/presentation/widgets/add_edit_product_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ProductsListWidget extends StatefulWidget {
  final List<Product> products;
  final int total;
  const ProductsListWidget(
      {super.key, required this.products, required this.total});

  @override
  State<ProductsListWidget> createState() => _ProductsListWidgetState();
}

class _ProductsListWidgetState extends State<ProductsListWidget> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();

    // String formate =
    //    "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  showUpdateDeleteDialog(context, widget.products[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Color.fromARGB(255, 165, 178, 214),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Flexible(
                                  child: Text(
                                    widget.products[index].name,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(
                                  DateTime.parse(widget.products[index].date)
                                      .toLocal()),
                              // products[index].date,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[400]),
                            ),
                            Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Flexible(
                                  child: Text(
                                    'السعر: ${widget.products[index].price}',
                                    softWrap: true,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(
                                  DateTime.parse(widget.products[index].date)
                                      .toLocal()),
                              // products[index].date,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[400]),
                            ),
                            Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Flexible(
                                  child: Text(
                                    'الوزن: ${widget.products[index].weight}',
                                    softWrap: true,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

/*
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        final isExpanded = expandedIndex == index;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: InkWell(
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(
                    color: const Color.fromARGB(255, 165, 178, 214),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main row (Name + Arrow)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                        Expanded(
                          child: Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Expanded content
                    if (isExpanded)
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //const SizedBox(height: 10),
                              // Price + Edit button inline
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showUpdateDeleteDialog(context, product);
                                    },
                                    icon: const Icon(Icons.edit,
                                        size: 20, color: Colors.blue),
                                    tooltip: "تعديل",
                                  ),
                                  Expanded(
                                    child: Directionality(
                                      textDirection: ui.TextDirection.rtl,
                                      child: Text(
                                        'السعر: ${product.price}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              //const SizedBox(height: 6),
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Text(
                                  'الوزن: ${product.weight}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                DateFormat('dd/MM/yyyy, HH:mm').format(
                                    DateTime.parse(product.date).toLocal()),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    */
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
                      textDirection: ui.TextDirection.rtl,
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
