import 'package:flutter/material.dart';

Future<Null> normalDialog(
    BuildContext context, String title) async {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Center(child: Text(title)),
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
