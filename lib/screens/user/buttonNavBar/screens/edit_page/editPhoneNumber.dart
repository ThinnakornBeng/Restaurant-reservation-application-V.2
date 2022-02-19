import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EditPhoneNumberUser extends StatefulWidget {
  const EditPhoneNumberUser({Key key}) : super(key: key);

  @override
  _EditPhoneNumberUserState createState() =>
      _EditPhoneNumberUserState();
}

class _EditPhoneNumberUserState extends State<EditPhoneNumberUser> {
  double screens;
  UserModel userModel;
  String nameUserLogin, urlImageProfile, uidUser, newPhone;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataUserLogin();
  }

  Future<Null> readDataUserLogin() async {
    Firebase.initializeApp().then(
      (value) async {
        FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            uidUser = event.uid;
            FirebaseFirestore.instance
                .collection('userTable')
                .doc(uidUser)
                .snapshots()
                .listen(
              (event) async {
                setState(
                  () {
                    userModel = UserModel.fromMap(
                      event.data(),
                    );
                  },
                );
                urlImageProfile = userModel.imageProfile;
                nameUserLogin = userModel.name;
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screens = MediaQuery.of(context).size.width;
    // print(uidUser);
    // print(nameUserLogin);
    // print(lastname);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
              onPressed: () {
                if (newPhone?.isEmpty ?? true) {
                  normalDialog(context, 'Please enter your phone number');
                } else {
                  upDatePhoneNumber();
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                Icons.save,
                size: 30,
              ))
        ],
        title: Container(
          margin: EdgeInsets.only(
            right: 10,
          ),
          child: Center(
            child: Text(
              'แก้ไขหมายเลขโทรศัพท์',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: userModel == null
          ? MyStyle().showProgress()
          : Column(
              children: [
                textName(),
                textfieldName(),
              ],
            ),
    );
  }

  Future<Null> upDatePhoneNumber() async {
    await Firebase.initializeApp().then(
      (value) async {
        FirebaseFirestore.instance
            .collection('userTable')
            .doc(uidUser)
            .update({"phoneUser": newPhone}).then((value) {});
      },
    );
  }

  Widget textLastName() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(
          top: 10,
        ),
        child: Row(
          children: [
            Text(
              'Last name',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget textName() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(
          top: 20,
        ),
        child: Row(
          children: [
            Text(
              'หมายเลขโทรศัพท์มือถือ',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget textfieldName() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 10),
        width: screens * 0.8,
        child: TextField(
          onChanged: (value) => newPhone = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.phone,
              color: Colors.red,
            ),
            label: Text(userModel.phoneUser),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.redAccent,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
