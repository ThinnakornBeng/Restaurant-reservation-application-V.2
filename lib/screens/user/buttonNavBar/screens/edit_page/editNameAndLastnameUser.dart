import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EditNameAndLastnameUser extends StatefulWidget {
  const EditNameAndLastnameUser({Key key}) : super(key: key);

  @override
  _EditNameAndLastnameUserState createState() =>
      _EditNameAndLastnameUserState();
}

class _EditNameAndLastnameUserState extends State<EditNameAndLastnameUser> {
  double screens;
  UserModel userModel;
  String nameUserLogin, urlImageProfile, uidUser, newName;

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
                if (newName?.isEmpty ?? true) {
                  normalDialog(context, 'Please enter your name and lastname');
                } else {
                  upDateNameAndLastName();
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
              'แก้ไขชื่อผู้ใช้งาน',
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

  Future<Null> upDateNameAndLastName() async {
    await Firebase.initializeApp().then(
      (value) async {
        FirebaseFirestore.instance
            .collection('userTable')
            .doc(uidUser)
            .update({"name": newName}).then((value) {});
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
              'ชื่อผู้ใช้งาน',
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
          onChanged: (value) => newName = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Colors.red,
            ),
            label: Text(nameUserLogin),
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
