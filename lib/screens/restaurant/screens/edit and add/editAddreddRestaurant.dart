import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EditAddressRestaurant extends StatefulWidget {
  const EditAddressRestaurant({Key key}) : super(key: key);

  @override
  _EditAddressRestaurantState createState() => _EditAddressRestaurantState();
}

class _EditAddressRestaurantState extends State<EditAddressRestaurant> {
  UserModel userModel;
  RestaurantModel restaurantModel;
  String newAddress, address, uidUser;

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
                address = restaurantModel.address;
                print('Restaurant Model is ==== $restaurantModel');
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
          'แก้ไขที่อยู่ร้านอาหาร',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
              onPressed: () {
                if (newAddress?.isEmpty ?? true) {
                  normalDialog(context, 'กรุณากรอกที่อยู่ของคุณ');
                } else {
                  upDateAddressForRestaurant();
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
                      onChanged: (value) => newAddress = value.trim(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.fmd_good,
                          size: 30,
                          color: Colors.redAccent,
                        ),
                        label: Text(address),
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

  Future<Null> upDateAddressForRestaurant() async {
    await Firebase.initializeApp().then(
      (value) async {
        FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidUser)
            .update({"address": newAddress}).then((value) {});
      },
    );
  }
}
