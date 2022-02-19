import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EditPhoneNumberRest extends StatefulWidget {
  const EditPhoneNumberRest({Key key}) : super(key: key);

  @override
  _EditPhoneNumberRestState createState() => _EditPhoneNumberRestState();
}

class _EditPhoneNumberRestState extends State<EditPhoneNumberRest> {
  UserModel userModel;
  RestaurantModel restaurantModel;
  String newPhoneNumberRest, phoneRest, uidUser;

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
                phoneRest = restaurantModel.phoneRest;
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
          'แก้ไขหมายเลขโทรศัพท์',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
              onPressed: () {
                if (newPhoneNumberRest?.isEmpty ?? true) {
                  normalDialog(context, 'กรุณากรอกที่อยู่ของคุณ');
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
                      onChanged: (value) => newPhoneNumberRest = value.trim(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.fmd_good,
                          size: 30,
                          color: Colors.redAccent,
                        ),
                        label: Text(phoneRest),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
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
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Future<Null> upDatePhoneNumber() async {
    await Firebase.initializeApp().then(
      (value) async {
        FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidUser)
            .update(
          {
            "phoneRest": newPhoneNumberRest,
          },
        ).then((value) {});
      },
    );
  }
}
