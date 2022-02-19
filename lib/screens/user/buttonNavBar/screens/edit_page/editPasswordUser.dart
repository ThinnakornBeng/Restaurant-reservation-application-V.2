import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EditPasswordUser extends StatefulWidget {
  const EditPasswordUser({Key key}) : super(key: key);

  @override
  _EditPasswordUserState createState() => _EditPasswordUserState();
}

class _EditPasswordUserState extends State<EditPasswordUser> {
  double screens;
  UserModel userModel;
  String uidUser, password, pass, newPassword, conFirmPassword;
  bool statusRedEy = true;

  final formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  newPassword = passwordController.text;
                  await Firebase.initializeApp().then((value) async {
                    await FirebaseAuth.instance
                        .authStateChanges()
                        .listen((event) async {
                      var object;
                      event.updatePassword(newPassword).then((value) {
                        print('Update Password Success');
                        // upDatePassword();
                      });
                    });
                  });
                }
              },
              icon: Icon(
                Icons.save,
                size: 30,
              ))
        ],
        title: Container(
          margin: EdgeInsets.only(right: 10),
          child: Center(
            child: Text(
              'เปลี่นรหัสผ่าน',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: userModel == null
          ? MyStyle().showProgress()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      newPrasswordForm(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget newPrasswordForm() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextFormField(
          controller: passwordController,
          validator: (value) {
            if (value.isEmpty) {
              return 'กรุณากรอกรหัสผ่าน';
            } else {
              if (value.length < 6) {
                return 'รหัสผ่านของคุณต้องมากกว่า 6 ต่ำแหน่ง';
              } else {
                return null;
              }
            }
          },
          obscureText: statusRedEy,
          decoration: InputDecoration(
            label: Text(
              'กรุณาใส่รหัสผ่านที่ต้องการเปลี่ยน',
            ),
            prefixIcon: Icon(
              Icons.password_rounded,
              color: Colors.redAccent,
            ),
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
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
      );
}
