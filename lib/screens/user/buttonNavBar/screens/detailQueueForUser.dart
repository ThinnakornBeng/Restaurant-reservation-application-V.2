import 'package:b_queue/model/queue_model.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/chatRoomUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailQueueForUser extends StatefulWidget {
  final QueueModel queueModel;
  const DetailQueueForUser({
    Key key,
    @required this.queueModel,
  }) : super(key: key);

  @override
  _DetailQueueForUserState createState() => _DetailQueueForUserState();
}

class _DetailQueueForUserState extends State<DetailQueueForUser> {
  QueueModel queueModel;
  int sumQueue;
  List<String> users = [];

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.queueModel = widget.queueModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการจองคิว'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 25),
              width: 350,
              height: 350,
              child: Card(
                // color: Colors.grey,
                child: Column(
                  children: [
                    Container(
                      // color: Colors.green,
                      height: 103,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              child: ClipOval(
                                child: Image.network(
                                  queueModel.urlImageRest,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            // color: Colors.yellow,
                            margin: EdgeInsets.only(left: 10, top: 10),
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.41,
                                      margin: EdgeInsets.only(top: 5),
                                      child:
                                          Text('ร้าน ${queueModel.nameRest}'),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        margin: EdgeInsets.only(
                                          top: 5,
                                        ),
                                        child: Text(
                                            'ที่อยู่ ${queueModel.address}')),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        margin: EdgeInsets.only(
                                          top: 5,
                                        ),
                                        child: Text(
                                            'เบอร์ ${queueModel.phoneRest}')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 15),
                              height: 90,
                              width: MediaQuery.of(context).size.width * 0.2,
                              // color: Colors.black,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      queueModel.queueStatus == false
                                          ? Text(
                                              'กำลังรอคิว',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )
                                          : Text(
                                              'สำเร็จ',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            )
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 15),
                                    height: 30,
                                    width: 30,
                                    // color: Colors.red,
                                    child: Center(
                                      child: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatroomUser(
                                                    queueModel: queueModel,
                                                    chatRoomId:
                                                        queueModel.uidUser,
                                                  ),
                                                ));
                                          },
                                          icon: Icon(
                                            Icons.message,
                                            color: Colors.blue,
                                          )),
                                    ),
                                  )
                                ],
                              ))
                        ],
                      ),
                    ),
                    divider(),
                    Container(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('images/clock.png'),
                          divider(),
                          divider(),
                          Container(
                            // color: Colors.yellow,
                            margin: EdgeInsets.only(left: 10, top: 10),
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.table_chart,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      margin: EdgeInsets.only(top: 5, left: 10),
                                      child: Text(queueModel.tableType),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        margin:
                                            EdgeInsets.only(top: 5, left: 10),
                                        child: Text(queueModel.peopleAmount)),
                                  ],
                                ),
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
                              Text(changeDateToString(queueModel.time)),
                              Text('วันที่จอง'),
                            ],
                          )),
                          divider(),
                          divider(),
                          Container(
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
            ),
          ),
          // Text('sumQueue $sumQueue')
        ],
      ),
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
