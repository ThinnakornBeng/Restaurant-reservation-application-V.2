import 'package:b_queue/model/queue_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ServiceHistory extends StatefulWidget {
  const ServiceHistory({Key key}) : super(key: key);

  @override
  State<ServiceHistory> createState() => _ServiceHistoryState();
}

class _ServiceHistoryState extends State<ServiceHistory> {
  var statusLoad = true;
  var statusHaveData = false;
  var queueModels = <QueueModel>[];
  int index;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataQueueRestaurant();
  }

  Future<void> readDataQueueRestaurant() async {
    if (queueModels.isEmpty) {
      queueModels.clear();
    }
    await Firebase.initializeApp().then((valuea) async {
      FirebaseAuth.instance.authStateChanges().listen((event) {
        FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(event.uid)
            .collection('restaurantQueueTable')
            .get()
            .then((value) {
          setState(() {
            statusLoad = false;
          });
          for (var item in value.docs) {
            QueueModel queueModel = QueueModel.fromMap(item.data());
             
            if (queueModel.waitStatus) {
             setState(() {
                queueModels.add(queueModel);
                statusHaveData = true;
              });
            }
            print(queueModels);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ประวัติการเข้าใช้บริการ',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: queueModels.length,
          itemBuilder: (context, index) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             queueModels[index].waitStatus == true ?  Container(
                margin: EdgeInsets.only(top: 10),
                height: 40,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(50)),
                child: Container(
                  margin: EdgeInsets.only(left: 20, top: 6),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                      "คุณ ${queueModels[index].nameUser} ไม่เข้าใช้บริการ"),
                ),
              ) :  Container(
                margin: EdgeInsets.only(top: 10),
                height: 40,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(50)),
                child: Container(
                  margin: EdgeInsets.only(left: 20, top: 6),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                      "คุณ ${queueModels[index].nameUser} รอเข้าใช้บริการ"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
