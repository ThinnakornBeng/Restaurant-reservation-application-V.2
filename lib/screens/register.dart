import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/restaurant/navbar/navRest.dart';
import 'package:b_queue/screens/user/navbar/navUser.dart';
import 'package:b_queue/utility/colors.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterApp extends StatefulWidget {
  @override
  _RegisterAppState createState() => _RegisterAppState();
}

class _RegisterAppState extends State<RegisterApp> {
  bool statusRedEye = true;
  bool statusRedEy = true;
  String name, email, password, typeUser, phoneNumber;
  double screens;
  String imageProfile =
      'https://firebasestorage.googleapis.com/v0/b/bengqueueproject2.appspot.com/o/Profile%2FDeflutProfile%2F1.png?alt=media&token=ca98b383-8791-477a-bf59-941f99091306';

  @override
  Widget build(BuildContext context) {
    screens = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Container(
          child: Text(
            'สร้างบัญชีผู้ใช้งาน',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: ''),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    width: screens * 0.4,
                    child: Image.asset(
                      'images/logo.png',
                      width: screens * 0.4,
                    )),
                userNameForm(),
                // userLastNameForm(),
                title(),
                methodTypeUser(),
                methodTypeRestaurant(),
                emailForm(),
                prasswordForm(),
                phoneNumberForm(),
                // confrimPrasswordForm(),
                saveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container saveButton() {
    return Container(
      height: 45,
      margin: EdgeInsets.only(top: 15),
      width: screens * 0.5,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          if ((name?.isEmpty ?? true) ||
              (email?.isEmpty ?? true) ||
              (password?.isEmpty ?? true) ||
              (phoneNumber?.isEmpty ?? true)) {
            normalDialog(
                context, 'Please enter your information ian all fields.');
          } else if (typeUser?.isEmpty ?? true) {
            normalDialog(context, 'Please your choose type user.');
          } else {
            createAccountAndInsertInformation();
          }
        },
        child: Text(
          'สร้างบัญชี',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Future<Null> createAccountAndInsertInformation() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then(
        (value) async {
          // print(
          //     'Create Account Success Name ==>> $name typeUser ==>> $typeUser Emai ==>> $email Password ==>> $password');
          // await value.user.updateProfile(displayName: name).then(
          await value.user.updateDisplayName(name).then(
            (value2) async {
              String uid = value.user.uid;
              // print('Update Profile Succress And uid ==>> $uid');
              UserModel model = UserModel(
                email: email,
                name: name,
                userType: typeUser,
                imageProfile: imageProfile,
                phoneUser: phoneNumber,
              );
              Map<String, dynamic> data = model.toMap();
              await FirebaseFirestore.instance
                  .collection('userTable')
                  .doc(uid)
                  .set(data)
                  .then((value) {
                print('Insert value to Firestore Succerss');
                switch (typeUser) {
                  case 'user':
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavigationBarUser(),
                        ),
                        (route) => false);
                    break;

                  case 'restaurant':
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavigationBarRestaurant(),
                        ),
                        (route) => false);
                    break;
                  default:
                }
              });
            },
          );
        },
      ).catchError(
        (onError) => normalDialog(context, onError.code),
      );
    }
        // print(
        //   'Firebase InitializaApp Success ',
        // );

        );
  }

  Container methodTypeUser() {
    return Container(
      width: screens * 0.8,
      child: RadioListTile(
        activeColor: primaryColor,
        value: 'user',
        groupValue: typeUser,
        onChanged: (value) {
          setState(() {
            typeUser = value;
          });
        },
        title: Text(
          'สำหรับลูกค้า',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Container methodTypeRestaurant() {
    return Container(
      width: screens * 0.8,
      child: RadioListTile(
        activeColor: primaryColor,
        value: 'restaurant',
        groupValue: typeUser,
        onChanged: (value) {
          setState(() {
            typeUser = value;
          });
        },
        title: Text(
          'สำหรับร้านอาหาร',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Container title() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: screens * 0.7,
      child: Text(
        'ประเภทผู้ใช้งาน:',
        style: TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget userNameForm() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          onChanged: (value) => name = value.trim(),
          decoration: InputDecoration(
            label: Text(
              'กรุณากรอกชื่อของคุณ',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            prefixIcon: Icon(
              Icons.account_box_rounded,
              color:  primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color:  primaryColor),
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
      );

  // Widget userLastNameForm() => Container(
  //       width: screens * 0.8,
  //       margin: EdgeInsets.only(top: 10),
  //       child: TextField(
  //         onChanged: (value) => lastName = value.trim(),
  //         decoration: InputDecoration(
  //           label: Text(
  //             'Please enter your last name',
  //             style: TextStyle(
  //               color: Colors.black54,
  //             ),
  //           ),
  //           prefixIcon: Icon(
  //             Icons.account_box_rounded,
  //             color: Colors.red,
  //           ),
  //           enabledBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.red),
  //             borderRadius: BorderRadius.all(
  //               Radius.circular(20),
  //             ),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.orange),
  //             borderRadius: BorderRadius.all(
  //               Radius.circular(20),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );

  Widget emailForm() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => email = value.trim(),
          decoration: InputDecoration(
            label: Text(
              'กรุณากรอกอีเมลของคุณ',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            prefixIcon: Icon(
              Icons.email_rounded,
              color:  primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color:  primaryColor),
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
      );

  Widget prasswordForm() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          onChanged: (value) => password = value.trim(),
          obscureText: statusRedEy,
          decoration: InputDecoration(
            label: Text(
              'กรุณาใส่รหัสผ่านของคุณ',
              style: TextStyle(color: Colors.black54),
            ),
            prefixIcon: Icon(
              Icons.password_rounded,
              color:  primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color:  primaryColor),
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
      );

  Widget phoneNumberForm() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          keyboardType: TextInputType.phone,
          onChanged: (value) => phoneNumber = value.trim(),
          decoration: InputDecoration(
            label: Text(
              'กรุณากรอกหมายเลขโทรศัพท์ของท่าน',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            prefixIcon: Icon(
              Icons.phone,
              color:  primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color:  primaryColor),
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
      );

  // Widget confrimPrasswordForm() => Container(
  //       width: screens * 0.8,
  //       margin: EdgeInsets.only(top: 10),
  //       child: TextField(
  //         onChanged: (value) => conPassword = value.trim(),
  //         obscureText: statusRedEy,
  //         decoration: InputDecoration(
  //           label: Text(
  //             'Confirm password',
  //             style: TextStyle(color: Colors.black54),
  //           ),
  //           prefixIcon: Icon(
  //             Icons.password_rounded,
  //             color: Colors.red,
  //           ),
  //           enabledBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.red),
  //             borderRadius: BorderRadius.all(
  //               Radius.circular(20),
  //             ),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.orange),
  //             borderRadius: BorderRadius.all(
  //               Radius.circular(20),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
}
