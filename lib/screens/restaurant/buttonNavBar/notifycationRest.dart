import 'package:b_queue/model/detail_notification_model.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NotifycationRest extends StatefulWidget {
  const NotifycationRest({Key key}) : super(key: key);

  @override
  _NotifycationRestState createState() => _NotifycationRestState();
}

class _NotifycationRestState extends State<NotifycationRest> {
  var detailNotificationModels = <DetailNotificationModel>[];
  var statusLoad = true;
  var statusHaveData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDetaiNotification();
  }

  Future<void> readDetaiNotification() async {
    if (detailNotificationModels.isEmpty) {
      detailNotificationModels.clear();
    }
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        await FirebaseFirestore.instance
            .collection('userTable')
            .doc(event.uid)
            .collection('detailNotificationTable')
            .get()
            .then((value) {
          setState(() {
            statusLoad = false;
          });
          for (var item in value.docs) {
            DetailNotificationModel detailNotificationModel =
                DetailNotificationModel.fromMap(item.data());

            setState(() {
              detailNotificationModels.add(detailNotificationModel);
              statusHaveData = true;
            });
            print(
                'DetailNotification Is $detailNotificationModels #################');
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            width: 60,
            height: 50,
          )
        ],
        title: Center(child: Text('BQueue')),
      ),
      body: statusLoad
          ? MyStyle().showProgress()
          : statusHaveData
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'การแจ้งเตือน',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: detailNotificationModels.length,
                        itemBuilder: (context, index) => Container(
                          child: Card(
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  child: Image.asset('images/logo.png'),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.68,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.67,
                                            child: Text(
                                                detailNotificationModels[index]
                                                    .title),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.67,
                                            child: Text(
                                                detailNotificationModels[index]
                                                    .body),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 55,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: Center(
                                    child: Icon(
                                      Icons.notifications,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text("Don't have detailnotification data"),
                ),
    );
  }
}
