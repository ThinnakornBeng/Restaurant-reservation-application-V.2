import 'dart:io';
import 'dart:math';

import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPhotoRestaurant extends StatefulWidget {
  const EditPhotoRestaurant({Key key}) : super(key: key);

  @override
  _EditPhotoRestaurantState createState() => _EditPhotoRestaurantState();
}

class _EditPhotoRestaurantState extends State<EditPhotoRestaurant> {
  String uidUser, urlImageRestaurant, newUrlImageRestaurant;

  File file;
// sceens
  double sceens;
// model
  UserModel userModel;
  RestaurantModel restaurantModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readRestaurant();
  }

  Future<Null> readRestaurant() async {
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            uidUser = event.uid;
            await FirebaseFirestore.instance.collection('userTable')
              ..doc(uidUser).snapshots().listen(
                (event) async {
                  userModel = UserModel.fromMap(
                    event.data(),
                  );
                  // print('User Model is ===== $userModel');
                },
              );
            await FirebaseFirestore.instance
                .collection('restaurantTable')
                .doc(uidUser)
                .snapshots()
                .listen(
              (event) async {
                setState(() {
                  restaurantModel = RestaurantModel.fromMap(event.data());
                });
                urlImageRestaurant = restaurantModel.urlImageRes;
                // print('Restaurant Model is ==== $restaurantModel');
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    sceens = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Center(
            child: Text(
          'แก้ไขโปรไฟล์ร้าน',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
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
      ),
      body: restaurantModel == null
          ? MyStyle().showProgress()
          : Center(
              child: Column(
                children: [
                  showImage(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'โปรดเลือกรูปภาพร้านอาหารของคุณ ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Container(
                    width: sceens * 0.8,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        choooseImage(ImageSource.camera);
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              'เลือกจากกล้อง',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: sceens * 0.8,
                    margin: EdgeInsets.only(
                      top: 15,
                    ),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        choooseImage(ImageSource.gallery);
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            child: Icon(
                              Icons.photo,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              'เลือกจากแกลเลอรี่',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  // Widget showImage() {
  //   return Container(
  //     width: 300,
  //     height: 300,
  //     child: file == null
  //         ? Image.network(
  //             urlImageRestaurant,
  //             fit: BoxFit.cover,
  //           )
  //         : Image.file(
  //             file,
  //             fit: BoxFit.cover,
  //           ),
  //   );
  // }

  Container showImage() {
    return Container(
      margin: EdgeInsets.only(top: 40),
      width: 200,
      height: 200,
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
                    urlImageRestaurant,
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    file,
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
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

  Future<Null> upLoadPictureToStoage() async {
    Random random = Random();
    int i = random.nextInt(1000000);

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('Restaurant/Restaurant$i.jpg');
    UploadTask uploadTask = reference.putFile(file);

    newUrlImageRestaurant = await (await uploadTask).ref.getDownloadURL();
    print('UrlImage ===>>> $newUrlImageRestaurant');

    upDatePictureToCloudFriestore();
  }

  Future<Null> upDatePictureToCloudFriestore() async {
    Firebase.initializeApp().then(
      (value) async {
        FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidUser)
            .update({"urlImageRes": newUrlImageRestaurant}).then(
          (value) async {},
        );
      },
    );
  }
}
