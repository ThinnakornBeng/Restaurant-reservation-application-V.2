import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/user/buttonNavBar/listUser.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/nodata_qr_code.dart';
import 'package:b_queue/screens/user/buttonNavBar/storeUser.dart';
import 'package:b_queue/screens/user/buttonNavBar/notificationUser.dart';
import 'package:b_queue/screens/user/buttonNavBar/seach_page.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/addQueueUser.dart';
import 'package:b_queue/screens/user/navbar/account.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/notifyDialog.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:raw_scanner/raw_scanner.dart';

class NavigationBarUser extends StatefulWidget {
  const NavigationBarUser({Key key}) : super(key: key);

  @override
  _NavigationBarUserState createState() => _NavigationBarUserState();
}

class _NavigationBarUserState extends State<NavigationBarUser> {
  List<Widget> listButtons = [
    HomeUser(),
    Search(),
    ListUser(),
    NotificationUser(),
  ];
  int indexPages = 0;
  String nameLogin, urlImageUser, email, password;
  UserModel userModel;
  String scanResults;

  @override
  void initState() {
    super.initState();
    readUidLogin();
    forNotification();
  }

  Future<void> forNotification() async {
    // for FonEnd Service
    FirebaseMessaging.onMessage.listen((event) {
      String titleNoti = event.notification.title;
      String bodyNoti = event.notification.body;
      print(
          'Form Fontend User titleNoti == $titleNoti, bodeyNoti == $bodyNoti');
      notifyDialog(context, '$titleNoti $bodyNoti');
    });

    // for BlackEnd Service
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      String titleNoti = event.notification.title;
      String bodyNoti = event.notification.body;
      print(
          'form BlackEnd User titleNoti == $titleNoti, bodeyNoti == $bodyNoti');
      normalDialog(context, '$titleNoti \n $bodyNoti');
    });
  }

  Future<Null> readUidLogin() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uid = event.uid;
        // print('Uid = $uid');
        await FirebaseFirestore.instance
            .collection('userTable')
            .doc(uid)
            .snapshots()
            .listen((event) {
          setState(() {
            userModel = UserModel.fromMap(event.data());
            // String nameLogin = userModel.name;
            // print('NameLogin ====>>>> $nameLogin');
            urlImageUser = userModel.imageProfile;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              scanResults = await RawScanner.scanCode(
                  title: Text(
                    'สแกนคิวอาร์โค้ด',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  typeOfCode: BarcodeFormat.qrcode,
                  context: context);

              print(scanResults);
              if (scanResults != null) {
                await Firebase.initializeApp().then((value) async {
                  FirebaseFirestore.instance
                      .collection('restaurantTable')
                      .doc(scanResults)
                      .get()
                      .then((value) {
                    if (value.data() != null) {
                      print('Valeu ====>>>> ${value.data()}');
                      RestaurantModel restaurantModel =
                          RestaurantModel.fromMap(value.data());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddQueueUser(
                            model: restaurantModel,
                            uidRest: scanResults,
                          ),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  });
                });
              }
            },
            icon: Icon(
              Icons.qr_code_scanner_sharp,
              size: 35,
            )),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => AccountUser(),
          //       ),
          //     );
          //   },
          //   icon: Icon(
          //     Icons.face_sharp,
          //     size: 40,
          //     color: Colors.white,
          //   ),
          // ),
          Container(
            width: 60,
            height: 50,
            margin: EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountUser(),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: ClipOval(
                  child: userModel == null
                      ? Image.asset(
                          'images/logo.png',
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          userModel.imageProfile,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.redAccent,
        title: Center(
          child: Text(
            'BQueue',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
      body: listButtons[indexPages],
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  BottomNavigationBar bottomNavigationBar() => BottomNavigationBar(
        backgroundColor: Colors.redAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: indexPages,
        onTap: (value) {
          setState(() {
            indexPages = value;
          });
        },
        items: [
          storeUserNav(),
          searchUser(),
          historyUserNav(),
          notificationUserNav(),
        ],
      );

  BottomNavigationBarItem storeUserNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.store_mall_directory_sharp,
        size: 30,
      ),
      label: 'ร้านอาหาร',
    );
  }

  BottomNavigationBarItem searchUser() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.search,
        size: 30,
      ),
      label: 'ค้นหา',
    );
  }

  BottomNavigationBarItem historyUserNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.menu_book_rounded,
        size: 30,
      ),
      label: 'ราการจอง',
    );
  }

  BottomNavigationBarItem notificationUserNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.notifications,
        size: 30,
      ),
      label: 'แจ้งเตือน',
    );
  }
}
