import 'dart:io';
import 'dart:math';

import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPhotoProfileUser extends StatefulWidget {
  const EditPhotoProfileUser({Key key}) : super(key: key);

  @override
  _EditPhotoProfileUserState createState() => _EditPhotoProfileUserState();
}

class _EditPhotoProfileUserState extends State<EditPhotoProfileUser> {
  double screens;
  UserModel userModel;
  String urlImageProfile, uidUser, newUrlImageProfile;
  File file;

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
    // print(urlImageProfile);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                upLoadPictureToStoage();
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
              'แก้ไขรูปโปรไฟล์',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: urlImageProfile == null
          ? MyStyle().showProgress()
          : Center(
              child: Column(
                children: [
                  showImage(),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'โปรดเลือกโปรไฟล์รูปภาพของคุณ ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () => choooseImage(ImageSource.camera),
                      child: Container(
                        width: screens * 0.7,
                        child: Card(
                          color: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  )),
                              Text(
                                'เลือกจากกล้อง',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () => choooseImage(ImageSource.gallery),
                      child: Container(
                        width: screens * 0.7,
                        child: Card(
                          color: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.photo,
                                    size: 30,
                                    color: Colors.white,
                                  )),
                              Text(
                                'เลือกจากแกลเลอรี่',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Container showImage() {
    return Container(
      margin: EdgeInsets.only(top: 40),
      width: 190,
      height: 180,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        shadowColor: Colors.red,
        child: Center(
          child: ClipOval(
            child: file == null
                ? Image.network(
                    urlImageProfile,
                    width: screens * 0.5,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    file,
                    width: screens * 0.5,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }

  Future<Null> upLoadPictureToStoage() async {
    Random random = Random();
    int i = random.nextInt(1000000);

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('Profile/ImageProfile$i.jpg');
    UploadTask uploadTask = reference.putFile(file);

    newUrlImageProfile = await (await uploadTask).ref.getDownloadURL();
    print('UrlImage ===>>> $newUrlImageProfile');

    upDatePictureToCloudFriestore();
  }

  Future<Null> upDatePictureToCloudFriestore() async {
    Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('userTable')
          .doc(uidUser)
          .update({"imageProfile": newUrlImageProfile}).then(
        (value) async {},
      );
    });
  }

  Future<Null> choooseImage(ImageSource imageSource) async {
    try {
      var object = await ImagePicker().getImage(
        source: imageSource,
        maxHeight: 500,
        maxWidth: 500,
      );
      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }
}
