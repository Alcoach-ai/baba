import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
