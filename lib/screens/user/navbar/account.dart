import 'dart:io';

import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/authtication.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/edit_page/editNameAndLastnameUser.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/edit_page/editPasswordUser.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/edit_page/editPhoneNumber.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/edit_page/editPhotoProfileUser.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountUser extends StatefulWidget {
  @override
  _AccountUserState createState() => _AccountUserState();
}

class _AccountUserState extends State<AccountUser> {
  UserModel userModel;
  File file;
  String imageUsser, email, password, nameLogin, lastName, phoneUser;

  @override
  void initState() {
    super.initState();
    readUidLogin();
  }

  Future<Null> readUidLogin() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uid = event.uid;
        await FirebaseFirestore.instance
            .collection('userTable')
            .doc(uid)
            .snapshots()
            .listen((event) {
          setState(() {
            userModel = UserModel.fromMap(event.data());
          });
          nameLogin = userModel.name;
          imageUsser = userModel.imageProfile;
          email = userModel.email;
          phoneUser = userModel.phoneUser;

          // print('NameLogin ====>>>> $nameLogin');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: userModel == null
          ? MyStyle().showProgress()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50, right: 15),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                          iconSize: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'โปรไฟล์',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  showImage(),
                  Container(
                    height: MediaQuery.of(context).size.width * 1.28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      children: [
                        editName(),
                        divider(),
                        showEmailUser(),
                        divider(),
                        showPhoneNumberUser(),
                        divider(),
                        editPassword(),
                        divider(),
                        showTextAboutTheApplication(),
                        divider(),
                        signOut(),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Divider divider() {
    return Divider(
      height: 20,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.black26,
    );
  }

  Widget signOut() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(left: 10, right: 20),
      child: ListTile(
        onTap: () async {
          await Firebase.initializeApp().then((value) async {
            await FirebaseAuth.instance
                .signOut()
                .then((value) => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Authentication(),
                    ),
                    (route) => false));
          });
        },
        trailing: Icon(
          Icons.exit_to_app_outlined,
          color: Colors.redAccent,
        ),
        title: Text(
          'ออกจากระบบ',
          style: TextStyle(
            fontSize: 18,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget showTextAboutTheApplication() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(left: 10, right: 20),
      child: ListTile(
        onTap: () {
          normalDialog(context, 'พัฒนาโดย Thinnakorn');
        },
        leading: Icon(
          Icons.error_outline_outlined,
          color: Colors.redAccent,
          size: 30,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          'เกี่ยวกับแอพพลิเคชั่น',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget editPassword() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(left: 10, right: 20),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPasswordUser(),
            ),
          );
        },
        leading: Icon(
          Icons.password_outlined,
          size: 30,
          color: Colors.redAccent,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          '*********',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget showPhoneNumberUser() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(left: 10, right: 20),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPhoneNumberUser(),
            ),
          );
        },
        leading: Icon(
          Icons.phone,
          size: 30,
          color: Colors.redAccent,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          phoneUser,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget showEmailUser() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(left: 10, right: 20),
      child: ListTile(
        onTap: () {
          normalDialog(context, email);
        },
        leading: Icon(
          Icons.email_rounded,
          size: 30,
          color: Colors.redAccent,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          email,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget editName() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(left: 10, right: 20, top: 20),
      child: ListTile(
        leading: Icon(
          Icons.person,
          size: 30,
          color: Colors.redAccent,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditNameAndLastnameUser(),
            ),
          );
        },
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          nameLogin,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget showImage() {
    return Container(
      width: 150,
      height: 150,
      child: userModel.imageProfile == null
          ? Card(
              shadowColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Stack(
              children: [
                Container(
                  width: 180,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPhotoProfileUser(),
                        ),
                      );
                    },
                    child: Card(
                      shadowColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          userModel.imageProfile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ClipOval(
                    child: Container(
                      color: Colors.white,
                      width: 35,
                      height: 35,
                      child: Icon(
                        Icons.edit,
                        color: Colors.redAccent,
                        size: 30,
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Future<Null> chooseImage(ImageSource imageSource) async {
    try {
      var objict = await ImagePicker().getImage(
        source: imageSource,
        maxHeight: 500,
        maxWidth: 500,
      );
      setState(() {
        file = File(objict.path);
      });
    } catch (e) {}
  }
}
