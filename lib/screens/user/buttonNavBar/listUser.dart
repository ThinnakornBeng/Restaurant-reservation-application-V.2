import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/listHistoryForUser.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/listQueueForUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ListUser extends StatefulWidget {
  const ListUser({Key key}) : super(key: key);

  @override
  _ListUserState createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  UserModel userModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLogindata();
  }

  Future<Null> readLogindata() async {
    Firebase.initializeApp().then(
      (value) async {
        await FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            String uid = event.uid;
            await FirebaseFirestore.instance
                .collection('userTable')
                .doc(uid)
                .snapshots()
                .listen(
              (event) {
                setState(
                  () {
                    UserModel userModel = UserModel.fromMap(
                      event.data(),
                    );
                    // print('UidLOogin For Detail List is $uid');
                    // print('name Login For Detail List is ${userModel.name}');
                  },
                );
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
      body: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          body: Column(
            children: [
              Container(color: Colors.redAccent,
                child: TabBar(
                  indicatorColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  labelColor: Colors.white,
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.description_sharp),
                    ),
                    Tab(
                      icon: Icon(Icons.history_outlined),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    ListQueueUser(),
                    ListHistoryUser(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
