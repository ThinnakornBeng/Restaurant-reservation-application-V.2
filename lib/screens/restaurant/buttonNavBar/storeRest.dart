import 'dart:io';

import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/restaurant/screens/edit%20and%20add/add_restaurant.dart';
import 'package:b_queue/screens/restaurant/screens/edit%20and%20add/editAddreddRestaurant.dart';
import 'package:b_queue/screens/restaurant/screens/edit%20and%20add/editNameRestrant.dart';
import 'package:b_queue/screens/restaurant/screens/edit%20and%20add/editPhoneRest.dart';
import 'package:b_queue/screens/restaurant/screens/edit%20and%20add/editPhotoRestaurant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StoreRestaurant extends StatefulWidget {
  @override
  _StoreRestaurantState createState() => _StoreRestaurantState();
}

class _StoreRestaurantState extends State<StoreRestaurant> {
  RestaurantModel restaurantModel;
  UserModel userModel;
  String uidUser, uidRest, name, image, address;
  bool status = true;
  File file;

  final genQRkey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // readDataRes();
    readUidLogin();
    readDataRes();
  }

  Future<Null> readDataRes() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen(
        (event) async {
          uidRest = event.uid;
        },
      );
    });
  }

  Future<Null> readUidLogin() async {
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            uidUser = event.uid;
            // print('Uid = $uidUser');
            await FirebaseFirestore.instance
                .collection('userTable')
                .doc(uidUser)
                .snapshots()
                .listen(
              (event) {
                setState(
                  () {
                    userModel = UserModel.fromMap(event.data());
                    String nameLogin = userModel.name;
                    // print('NameLogin ====>>>> $nameLogin');
                  },
                );
              },
            );
            await FirebaseFirestore.instance
                .collection('restaurantTable')
                .doc(uidRest)
                .snapshots()
                .listen(
              (event) async {
                setState(() {
                  restaurantModel = RestaurantModel.fromMap(event.data());
                });
                // print(restaurantModel);
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
      body: restaurantModel == null ? showNodata(context) : showHaveData(),
    );
  }

  Center showHaveData() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            showTextRestaurant(),
            showImage(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPhotoRestaurant(),
                      ),
                    );
                  },
                  child: Text(
                    'แก้ไขรูปร้านอาหาร',
                    style: TextStyle(fontSize: 16),
                  )),
            ),
            editNameRest(),
            editAddressRest(),
            editPhoneNumberRest(),qr_code(),
           
          ],
        ),
      ),
    );
  }

  Widget showTextRestaurant() => Container(
      margin: EdgeInsets.only(top: 15),
      child: Text(
        'ร้านของฉัน',
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ));

  Widget showImage() => GestureDetector(
        onTap: () {},
        child: Container(
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            width: 250,
            height: 250,
            child: Card(
                child: Image.network(
              restaurantModel.urlImageRes,
              fit: BoxFit.cover,
            ))),
      );

  Widget showNameRestaurant() => Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Icon(
              Icons.store_rounded,
              color: Colors.redAccent,
              size: 30,
            ),
            Container(
              margin: EdgeInsets.only(
                left: 10,
              ),
              child: Text(
                restaurantModel.nameRes,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );

  Center showNodata(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "ไม่มีข้อมูลรานอาหาร กรุณาเพิ่มข้อมูล",
            style: TextStyle(fontSize: 20),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRaetaurant(),
                )),
            child: Text(
              'เพิ่มข้อมูลร้านอาหาร',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget editPhoneNumberRest() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(
        left: 10,
        right: 20,
        top: 20,
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPhoneNumberRest(),
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
          restaurantModel.phoneRest,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget editAddressRest() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(
        left: 10,
        right: 20,
        top: 20,
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditAddressRestaurant(),
            ),
          );
        },
        leading: Icon(
          Icons.fmd_good_sharp,
          size: 30,
          color: Colors.redAccent,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          restaurantModel.address,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget editNameRest() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(
        left: 10,
        right: 20,
        top: 20,
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditNameRestaurant(),
            ),
          );
        },
        leading: Icon(
          Icons.store_mall_directory_sharp,
          size: 30,
          color: Colors.redAccent,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          restaurantModel.nameRes,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget qr_code() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(
        left: 10,
        right: 20,
        top: 20,
      ),
      child: ListTile(
        onTap: () {
          callTypeUserDialog();
        },
        leading: Icon(
          Icons.qr_code_rounded,
          size: 30,
          color: Colors.redAccent,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          'คิวอาร์โค้ด',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<Null> callTypeUserDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => SimpleDialog(
            title: ListTile(
              leading: Container(
                  width: 40, height: 40, child: Image.asset('images/logo.png')),
              title: Text('คิวอาร์โค้ด'),
              subtitle: Text('คิวอาร์โค้ดของร้าน'),
            ),
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [ Container(

              width: 200,
              height: 200,
              child: RepaintBoundary(
                key: genQRkey,
                child: QrImage(
                  data: uidUser,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // print(
                  //     ' Name == $name, TypeUser == $typeUser, Email == $email, Uid == $uid');
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}
