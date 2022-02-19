import 'package:b_queue/model/detail_notification_model.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NotificationUser extends StatefulWidget {
  const NotificationUser({Key key}) : super(key: key);

  @override
  _NotificationUserState createState() => _NotificationUserState();
}

class _NotificationUserState extends State<NotificationUser> {
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
              statusHaveData = true;
              detailNotificationModels.add(detailNotificationModel);
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
        body: statusLoad
            ? MyStyle().showProgress()
            : statusHaveData
                ? Column(
                  children: [ Padding(
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
                                    width: MediaQuery.of(context).size.width * 0.78,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width:
                                                  MediaQuery.of(context).size.width *
                                                      0.78,
                                              child: Text(
                                                  detailNotificationModels[index]
                                                      .title),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width:
                                                  MediaQuery.of(context).size.width *
                                                      0.78,
                                              child: Text(
                                                  detailNotificationModels[index]
                                                      .body),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ),
                  ],
                )
                : Center(child: Text("Don't have detailnotification data")));
  }
}
