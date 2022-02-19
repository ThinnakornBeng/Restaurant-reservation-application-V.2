import 'dart:io';
import 'dart:math';
import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AddRaetaurant extends StatefulWidget {
  @override
  _AddRaetaurantState createState() => _AddRaetaurantState();
}

class _AddRaetaurantState extends State<AddRaetaurant> {
  File file;
  double screens;
  String uidRes, nameRes, address, urlImage, token, phoneRest;
  UserModel userModel;
  Location location = Location();
  double lat, lng;
  @override
  void initState() {
    super.initState();
    readUidLogin();
    // findLatLng();
    findToken();
    findLocation();
  }

  Future<Null> findLocation() async {
    location.onLocationChanged.listen((event) {
      lat = event.latitude;
      lng = event.longitude;
      // print('Lat1 = $lat1, Lng1 = $lng1');
    });
  }

  Future<Null> findToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      token = value;
      print('############Token is $token ###############');
    });
  }

  Future<Null> readUidLogin() async {
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            uidRes = event.uid;
            // print('UidRestaurant = $uidRes');
            await FirebaseFirestore.instance
                .collection('userTable')
                .doc(uidRes)
                .snapshots()
                .listen(
              (event) {
                setState(
                  () {
                    userModel = UserModel.fromMap(event.data());
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Future<Null> findLatLng() async {
  //   LocationData locationData = await findLocationData();
  //   setState(
  //     () {
  //       lat = locationData.latitude;
  //       lng = locationData.longitude;
  //     },
  //   );
  //   print('lat = $lat, lng = $lng');
  // }

  // Future<LocationData> findLocationData() async {
  //   Location location = Location();
  //   try {
  //     return location.getLocation();
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    screens = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Container(
          margin: EdgeInsets.only(right: 30),
          child: Center(
            child: Text(
              'เพิ่มข้อมูลร้านอาหาร',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              showImage(),
              addImage(),
              nameRestaurant(),
              addressForm(),
              phoneNumberForm(),
              // showMap(),
              saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget showMap() {
  //   LatLng latLng = LatLng(lat, lng);
  //   CameraPosition cameraPosition = CameraPosition(
  //     target: latLng,
  //     zoom: 16.0,
  //   );
  //   return Container(
  //     height: 300.0,
  //     child: GoogleMap(
  //       initialCameraPosition: cameraPosition,
  //       mapType: MapType.normal,
  //       onMapCreated: (controller) {},
  //     ),
  //   );
  // }

  Widget showImage() => Container(
        margin: EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        width: 200,
        height: 200,
        child: file == null ? Image.asset('images/logo.png') : Image.file(file),
      );

  Widget addImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.photo,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () => choooseImage(
            ImageSource.gallery,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.photo_camera,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () => choooseImage(
            ImageSource.camera,
          ),
        ),
      ],
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

  Widget nameRestaurant() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          onChanged: (value) => nameRes = value.trim(),
          decoration: InputDecoration(
            hintText: 'ชื่อร้านอาหาร',
            prefixIcon: Icon(
              Icons.store_mall_directory_sharp,
              color: Colors.redAccent,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(20)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );

  Widget addressForm() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          onChanged: (value) => address = value.trim(),
          decoration: InputDecoration(
            hintText: 'ที่อยู่ร้านอาหาร',
            prefixIcon: Icon(
              Icons.place_rounded,
              color: Colors.redAccent,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(20)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.orange,
                ),
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );

  Widget phoneNumberForm() => Container(
        width: screens * 0.8,
        margin: EdgeInsets.only(top: 10),
        child: TextField(keyboardType: TextInputType.phone,
          onChanged: (value) => phoneRest = value.trim(),
          decoration: InputDecoration(
            hintText: 'เบอร์ร้านอาหาร',
            prefixIcon: Icon(
              Icons.phone,
              color: Colors.redAccent,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(20)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.orange,
                ),
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );

  Container saveButton() {
    return Container(
      height: 45,
      margin: EdgeInsets.only(top: 30),
      width: screens * 0.7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if ((nameRes?.isEmpty ?? true) ||
              (address?.isEmpty ?? true) ||
              (phoneRest?.isEmpty ?? true)) {
            normalDialog(context, 'กรุณากรอกข้อมูลของท่านทุกช่อง');
          } else if ((file == null)) {
            normalDialog(context, 'โปรดเลือกรูปภาพของคุณ');
          } else {
            uploadPictureToStoage();
          }
        },
        child: Text(
          'Save',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Future<Null> uploadPictureToStoage() async {
    Random random = Random();
    int i = random.nextInt(1000000);

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('Restaurant/Restaurant$i.jpg');
    UploadTask uploadTask = reference.putFile(file);

    urlImage = await (await uploadTask).ref.getDownloadURL();
    // print('UrlImage ===>>> $urlImage');
    addRestaurant();
  }

  Future<Null> addRestaurant() async {
    RestaurantModel restaurantModel = RestaurantModel(
      nameRes: nameRes,
      urlImageRes: urlImage,
      address: address,
      phoneRest: phoneRest,
      lat: lat,
      lng: lng,
      token: token,
    );
    Map<String, dynamic> data = restaurantModel.toMap();
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidRes)
            .set(data)
            .then(
          (value) {
            Navigator.pop(context);
            print('Success');
          },
        );
      },
    );
  }
}
