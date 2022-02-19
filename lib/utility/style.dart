import 'package:b_queue/screens/authtication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyStyle {
  Color darkColor = Colors.amber;
  Color primaryColor = Colors.orange;

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.red,
      ),
    );
  }

  Container showLogo() {
    return Container(
      width: 200.0,
      child: Image.asset(
        'images/logo.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Column buildSignOut(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(left: 20, top: 10),
          child: ListTile(
            onTap: () async {
              await Firebase.initializeApp().then(
                (value) async {
                  await FirebaseAuth.instance.signOut().then(
                        (value) => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Authentication(),
                            ),
                            (route) => false),
                      );
                },
              );
            },
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            title: Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  MyStyle();
}
