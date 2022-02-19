import 'package:flutter/material.dart';

Future<Null> notifyDialog(BuildContext context, String message) async {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => SimpleDialog(
          title: ListTile(
            leading: Container(
                width: 40, height: 40, child: Image.asset('images/logo.png')),
            title: Text('BQueue'),
            subtitle: Text('For Notification'),
          ),
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(message,style: TextStyle(fontSize: 16),),
                  Container(margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
