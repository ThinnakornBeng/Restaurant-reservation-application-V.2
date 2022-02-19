import 'dart:ui';

import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EditNameRestaurant extends StatefulWidget {
  const EditNameRestaurant({Key key}) : super(key: key);

  @override
  _EditNameRestaurantState createState() => _EditNameRestaurantState();
}

class _EditNameRestaurantState extends State<EditNameRestaurant> {
  UserModel userModel;
  RestaurantModel restaurantModel;
  String newNameRest, nameRest, uidUser;

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
                  userModel = UserModel.fromMap(event.data());
                  print('User Model is ===== $userModel');
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
                print('Restaurant Model is ==== $restaurantModel');
                nameRest = restaurantModel.nameRes;
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Center(
            child: Text(
          'แก้ไขชื่อร้านอาหาร',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
              onPressed: () {
                if (newNameRest?.isEmpty ?? true) {
                  normalDialog(context, 'กรุณากรอกชื่อร้านอาหารของคุณ');
                } else {
                  upDateNameRestaurant();
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                Icons.save,
                size: 30,
              ))
        ],
      ),
      body: restaurantModel == null
          ? MyStyle().showProgress()
          : Column(
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: EdgeInsets.only(top: 25),
                    child: TextField(
                      onChanged: (value) => newNameRest = value.trim(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.store_mall_directory,
                          size: 30,
                          color: Colors.red,
                        ),
                        label: Text(nameRest),
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
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            borderSide: BorderSide(
                              color: Colors.orange,
                            )),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Future<Null> upDateNameRestaurant() async {
    await Firebase.initializeApp().then(
      (value) async {
        FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidUser)
            .update(
          {
            "nameRes": newNameRest,
          },
        ).then((value) {});
      },
    );
  }
}
