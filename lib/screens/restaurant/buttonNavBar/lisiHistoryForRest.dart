import 'package:b_queue/model/queue_model.dart';
import 'package:b_queue/screens/restaurant/screens/detailQueueForRest.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListHistoryForRestaurant extends StatefulWidget {
  const ListHistoryForRestaurant({Key key}) : super(key: key);
  @override
  _ListHistoryForRestaurantState createState() =>
      _ListHistoryForRestaurantState();
}

class _ListHistoryForRestaurantState extends State<ListHistoryForRestaurant> {
  var queueModels = <QueueModel>[];
  var uidQueues = <String>[];
  var queueStatus = true;
  var statusLoad = true;
  var statusHaveData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readAllQueue();
    readUidQueue();
  }

  Future<void> readUidQueue() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uidRes = event.uid;
        await FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidRes)
            .collection('restaurantQueueTable')
            .get()
            .then((value) async {
          for (var item in value.docs) {
            String uidQueue = item.id;
            uidQueues.add(uidQueue);
          }
        });
        
      });
    });
  }

  Future<Null> readAllQueue() async {
    if (queueModels.isEmpty) {
      queueModels.clear();
    }
    await Firebase.initializeApp().then((value) async {
      FirebaseAuth.instance.authStateChanges().listen((event) async {
        await FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(event.uid)
            .collection('restaurantQueueTable')
            .orderBy('time', descending: false)
            .get()
            .then((value) {
          setState(() {
            statusLoad = false;
          });
          for (var item in value.docs) {
            QueueModel queueModel = QueueModel.fromMap(item.data());
            if (queueModel.queueStatus) {
              setState(() {
                queueModels.add(queueModel);
                statusHaveData = true;
              });
            }
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
                                    builder: (context) => DetailQueueForRrst(
                                          queueModel: queueModels[index],
                                          uidQueue: uidQueues[index],
                                        )));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    child: ClipOval(
                                      child: Image.network(
                                        queueModels[index].urlImageUser,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      "คุณ ${queueModels[index].nameUser} ได้ทำการจองคิวจากร้านของคุณเมื่่อวันที่ ${changeDateToString(queueModels[index].time)} เวลา ${changeTimeToString(queueModels[index].time)}",
                                    ),
                                  ),
                                  // Text(
                                  //   ChangeData(time: queueModels[index].time)
                                  //       .changeTimeToString(),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: Text("Don't have list queue data")),
    );
  }

  String changeTimeToString(Timestamp time) {
    DateFormat timeFormat = new DateFormat.Hms();
    String timeStr = timeFormat.format(time.toDate());
    return timeStr;
  }

  String changeDateToString(Timestamp time) {
    DateFormat dateFormat = new DateFormat.yMd();
    String dateStr = dateFormat.format(time.toDate());
    return dateStr;
  }
}
