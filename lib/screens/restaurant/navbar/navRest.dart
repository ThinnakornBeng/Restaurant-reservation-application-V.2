import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/restaurant/buttonNavBar/chatDataSceens.dart';
import 'package:b_queue/screens/restaurant/buttonNavBar/lisiHistoryForRest.dart';
import 'package:b_queue/screens/restaurant/buttonNavBar/listQueueForRestaurant.dart';
import 'package:b_queue/screens/restaurant/buttonNavBar/notifycationRest.dart';
import 'package:b_queue/screens/restaurant/buttonNavBar/storeRest.dart';
import 'package:b_queue/screens/user/navbar/account.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/notifyDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NavigationBarRestaurant extends StatefulWidget {
  const NavigationBarRestaurant({Key key}) : super(key: key);

  @override
  _NavigationBarRestaurantState createState() =>
      _NavigationBarRestaurantState();
}

class _NavigationBarRestaurantState extends State<NavigationBarRestaurant> {
  List<Widget> listWidgets = [
    StoreRestaurant(),
    ListQueueForRestaurant(),
    ListHistoryForRestaurant(),
    ChatSceens(),
    // NotifycationRest(),
  ];
  int indexPage = 0;
  UserModel userModel;

  String urlImage;

  @override
  void initState() {
    // TODO: implement initState
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
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotifycationRest(),
                  ));
            },
            icon: Icon(
              Icons.notifications,
              size: 35,
            )),
        title: Center(child: Text('BQueue')),
        actions: [
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
      ),
      body: listWidgets[indexPage],
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  BottomNavigationBar bottomNavigationBar() => BottomNavigationBar(
        selectedItemColor: Colors.white,
        backgroundColor: Colors.red,
        unselectedItemColor: Colors.white,
        currentIndex: indexPage,
        onTap: (value) {
          setState(() {
            indexPage = value;
          });
        },
        items: [
          storeRestaurantNav(),
          listQueueRestaurantNav(),
          listHistoryRestaurantNav(),
          messageRestaurantNav(),
          // accountRestaurantNav(),
        ],
      );

  BottomNavigationBarItem storeRestaurantNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.store_mall_directory_sharp,
        size: 30,
      ),
      label: 'ร้าน',
    );
  }

  BottomNavigationBarItem listQueueRestaurantNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.list_alt_rounded,
        size: 30,
      ),
      label: 'รายการจอง',
    );
  }

  BottomNavigationBarItem messageRestaurantNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.message,
        size: 30,
      ),
      label: 'แชท',
    );
  }

  BottomNavigationBarItem listHistoryRestaurantNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.history_outlined,
        size: 30,
      ),
      label: 'ประวัติ',
    );
  }

  BottomNavigationBarItem accountRestaurantNav() {
    return BottomNavigationBarItem(
      backgroundColor: Colors.redAccent,
      icon: Icon(
        Icons.notifications,
        size: 30,
      ),
      label: 'Notify',
    );
  }
}
