import 'package:b_queue/model/queue_model.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/detailQueueForUser.dart';

import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListHistoryUser extends StatefulWidget {
  const ListHistoryUser({Key key}) : super(key: key);

  @override
  _ListHistoryUserState createState() => _ListHistoryUserState();
}

class _ListHistoryUserState extends State<ListHistoryUser> {
  var queueModels = <QueueModel>[];
  var load = true;
  var haveQueue = false; // NoData

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readAllQueue();
  }

  Future<Null> readAllQueue() async {
    if (queueModels.isEmpty) {
      queueModels.clear();
    }
    Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uidUserLoginen = event.uid;
        await FirebaseFirestore.instance
            .collection('restaurantTable')
            .get()
            .then(
          (value) async {
            setState(() {
              load = false;
            });
            for (var item in value.docs) {
              String docIdRestaurantTable = item.id;
              await FirebaseFirestore.instance
                  .collection('restaurantTable')
                  .doc(docIdRestaurantTable)
                  .collection('restaurantQueueTable')
                  .get()
                  .then((value) {
                for (var item in value.docs) {
                  QueueModel queueModel = QueueModel.fromMap(item.data());

                  if (queueModel.uidUser == uidUserLoginen) {
                    if (queueModel.queueStatus) {
                      setState(() {
                        haveQueue = true;
                        queueModels.add(queueModel);
                        print('have Queue ===>>> $haveQueue');
                      });
                    }
                  }
                }
              });
            }
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: load
          ? MyStyle().showProgress()
          : haveQueue
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'ประวัติการจองคิว',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: queueModels.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                       DetailQueueForUser(queueModel: queueModels[index])));
                          },
                          child: Container(
                            height: 80,
                            margin: EdgeInsets.only(right: 10, left: 10),
                            child: Card(
                              shadowColor: Colors.red,
                              child: Row(
                                children: [
                                  Container(
                                    width: 120,
                                    child: ClipOval(
                                      child: Image.network(
                                          queueModels[index].urlImageRest),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: MediaQuery.of(context).size.width *
                                        0.56,
                                    child: Column(
                                      children: [
                                        // Row(
                                        //   children: [
                                        //     Container(
                                        //       width:
                                        //           MediaQuery.of(context).size.width *
                                        //               0.54,
                                        //       margin: EdgeInsets.only(top: 5),
                                        //       child: Text(
                                        //           'คุณ : ${queueModels[index].nameUser}'),
                                        //     ),
                                        //   ],
                                        // ),
                                        Row(
                                          children: [
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.54,
                                                margin: EdgeInsets.only(
                                                  top: 5,
                                                ),
                                                child: Text(
                                                    'คุณได้จองคิวจากร้าน ${queueModels[index].nameRest}')),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.54,
                                                margin: EdgeInsets.only(
                                                  top: 5,
                                                ),
                                                child: Text(
                                                    'เมื่อ ${changeTimeToString(queueModels[index].time)}')),
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
                    ),
                  ],
                )
              : Center(
                  child: Text('No Queue'),
                ),
    );
  }

  String changeTimeToString(Timestamp time) {
    DateFormat dateFormat = DateFormat('dd/MMM/yyyy HH:mm');
    String timeStr = dateFormat.format(time.toDate());
    return timeStr;
  }
}
