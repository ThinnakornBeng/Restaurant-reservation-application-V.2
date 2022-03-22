import 'package:b_queue/model/detail_notification_model.dart';
import 'package:b_queue/model/queue_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/restaurant/navbar/navRest.dart';
import 'package:b_queue/screens/restaurant/screens/servide_history.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailQueueForRrst extends StatefulWidget {
  final QueueModel queueModel;
  final String uidQueue;
  const DetailQueueForRrst(
      {Key key, @required this.queueModel, @required this.uidQueue})
      : super(key: key);

  @override
  _DetailQueueForRrstState createState() => _DetailQueueForRrstState();
}

class _DetailQueueForRrstState extends State<DetailQueueForRrst> {
  QueueModel queueModel;
  var uidQueue;
  var queueStatus = true;
  var waitStatus = true;
  var body;
  var title;
  var dateNow = DateTime.now();
  var datimeCalculator;
  var a, b, c, d;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queueModel = widget.queueModel;
    uidQueue = widget.uidQueue;

    // print('UidQueue ==>> $dateNow');
    // print(queueModel.time.toDate());
    calculatorDateTime();
    // setDateTimeToInt();
  }

  Future<void> setDateTimeToInt() {
    DateFormat timeFormat = new DateFormat.Hm();
    a = timeFormat.format(datimeCalculator);
    b = timeFormat.format(dateNow);
    c = int.parse(a);
    d = int.parse(b);

    calculatorDateTime();
  }

  Future<void> calculatorDateTime() {
    DateFormat timeFormat = new DateFormat.Hm();

    if (queueModel != null) {
      if (queueModel.time.toDate() != dateNow) {
        datimeCalculator = queueModel.time.toDate().add(Duration(minutes: 1));
        print("Time QueueModel is ${queueModel.time.toDate()}");
        print("New time QueueModel is $datimeCalculator");
        a = timeFormat.format(datimeCalculator);
        b = timeFormat.format(dateNow);
        // print("DateTimeNow Is $dateNow");
        // print("DateTime QueueModel Add is $calculatorDateTime()");
        // var a = int.parse(datimeCalculator);
        if (a == b) {
          updateWaitStatus();
          print("Update success");
        } else {
          print('is not up date');
        }
      }
    } else {
      print('null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการจองคิว'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Card(
                color: Colors.redAccent[500],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            child: ClipOval(
                              child: Image.network(queueModel.urlImageUser),
                            ),
                          ),
                          Container(
                            // color: Colors.amber,
                            height: 70,
                            width: MediaQuery.of(context).size.width * 0.45,
                            margin: EdgeInsets.only(left: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      child: Text('คุณ ${queueModel.nameUser}'),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      child: Text(
                                          'เบอร์ติดต่อ ${queueModel.phonrUser}'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.21,
                            // color: Colors.green,
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                queueModel.queueStatus == false
                                    ? Text(
                                        'กำลังรอคิว',
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Text(
                                        'สำเร็จ',
                                        style: TextStyle(color: Colors.green),
                                      )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    divider(),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              child: Column(
                            children: [
                              Column(
                                children: [
                                  Text(queueModel.tableType),
                                  Text('ประเภทโต๊ะ'),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15, bottom: 10),
                                child: Column(
                                  children: [
                                    Text(changeDateToString(queueModel.time)),
                                    Text('วันที่จอง'),
                                  ],
                                ),
                              ),
                            ],
                          )),
                          divider(),
                          divider(),
                          Container(
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Text(queueModel.peopleAmount),
                                    Text('จำนวนคน'),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 15, bottom: 10),
                                  child: Column(
                                    children: [
                                      Text(changeTimeToString(queueModel.time)),
                                      Text('เวลาที่จอง'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            updateQueueStatus();
                            String uidUser = queueModel.uidUser;
                            // print('You click $uidUser');
                            await Firebase.initializeApp().then((value) async {
                              await FirebaseFirestore.instance
                                  .collection('userTable')
                                  .doc(uidUser)
                                  .get()
                                  .then((value) async {
                                UserModel userModel =
                                    UserModel.fromMap(value.data());
                                String token = userModel.token;
                                // print('Token Is ====>>>> $token');

                                this.title = 'คุณ ${queueModel.nameUser} ';
                                this.body =
                                    'ถึงคิวของคุณแล้วกรุณาไปใช้บริการภายใน 10 นาที';

                                var path =
                                    'https://www.androidthai.in.th/mea/bengapiNotification.php?isAdd=true&token=$token&title=$title&body=$body';

                                await Dio().get(path).then((value) {
                                  print('Value ===>>> $value');
                                });
                                addDetailNotification();
                              });
                            });
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NavigationBarRestaurant(),
                                ),
                                (route) => false);
                          },
                          child: Text('ส่งการแจ้งเตือน'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Row(
                              children: [
                                Text('ไม่เข้าใช้บริการ'),
                                IconButton(
                                  onPressed: () {
                                    updateWaitStatus();
                                  },
                                  icon: queueModel.waitStatus == null
                                      ? MyStyle().showProgress()
                                      : queueModel.waitStatus == false
                                          ? Icon(
                                              Icons
                                                  .star_border_purple500_outlined,
                                              size: 30,
                                              color: Colors.redAccent,
                                            )
                                          : Icon(
                                              Icons.star,
                                              size: 30,
                                              color: Colors.redAccent,
                                            ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'หมายเหตุ : ในการณีที่ไกล้ถึงคิวของลูกค้าให้ทำการส่งการแจ้งเตือนไปยังลูกค้า หรือในกรณีที่ลูกค้าไม่มาเข้าใช่บริการให้ทำการกดปุ่มดาวไว้',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 15),
              ),
            ),
            // Container(
            //   height: 30,
            //   width: MediaQuery.of(context).size.width,
            //   color: Colors.green,
            // ),
            Container(
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceHistory(),
                      ),
                    );
                  },
                  child: Text('ประวัติผู้ที่ไม่เข้าใช้บริการ')),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> addDetailNotification() async {
    await Firebase.initializeApp().then((value) async {
      DetailNotificationModel detailNotificationModel =
          DetailNotificationModel(title: title, body: body);
      Map<String, dynamic> data = detailNotificationModel.toMap();
      await FirebaseFirestore.instance
          .collection('userTable')
          .doc(queueModel.uidUser)
          .collection('detailNotificationTable')
          .doc()
          .set(data)
          .then((value) {
        print('Add Notification to database success');
      });
    });
  }

  Future<void> updateWaitStatus() async {
    Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('restaurantTable')
          .doc(queueModel.uidRest)
          .collection('restaurantQueueTable')
          .doc(uidQueue)
          .update({"waitStatus": waitStatus}).then((value) {
        // print('Uddate Queue Status Success');
      });
    });
  }

  Future<void> updateQueueStatus() async {
    Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('restaurantTable')
          .doc(queueModel.uidRest)
          .collection('restaurantQueueTable')
          .doc(uidQueue)
          .update({"queueStatus": queueStatus}).then((value) {
        print('Uddate Queue Status Success');
      });
    });
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

  Divider divider() {
    return Divider(
      height: 15,
      thickness: 1.5,
      indent: 15,
      endIndent: 15,
      color: Colors.black12,
    );
  }
}
