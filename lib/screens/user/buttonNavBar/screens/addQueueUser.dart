import 'package:b_queue/model/detail_notification_model.dart';
import 'package:b_queue/model/queue_model.dart';
import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/utility/colors.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:b_queue/utility/my_api_location.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class AddQueueUser extends StatefulWidget {
  final RestaurantModel model;
  final String uidRest;
  DateTime dateTime;
  AddQueueUser({Key key, this.model, this.uidRest}) : super(key: key);

  @override
  _AddQueueUserState createState() => _AddQueueUserState();
}

class _AddQueueUserState extends State<AddQueueUser> {
  String uidRes,
      typeTable,
      nameLogin,
      uidUser,
      date,
      time,
      peopleAmount,
      token,
      urlImageUser;

  bool statusHaveData = true;
  bool statusNoData = true;
  bool queueStatus = false;
  var waitStatus = false;
  double lat1, lng1, lat2, lng2, distance;
  Location location = Location();

  // Model
  RestaurantModel restaurantModel;
  UserModel userModel;
  List<QueueModel> queueModel = [];

  double screens;
  int amount = 0;
  int queueAmount;

  // DateTime
  var dateTimeNow;
  DateFormat dateFormat;
  DateFormat timeFormat;
  String distanceString;
  int transport;

  var title;
  var body;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataUidLogin();
    restaurantModel = widget.model;
    uidRes = widget.uidRest;
    dateFormat = new DateFormat.yMd();
    timeFormat = new DateFormat.Hms();
    initializeDateFormatting();
    findToken();
    readQueueData();
    if (queueAmount == null) {
      queueAmount = 0;
    }
    findLocation();
    // print(uidRes);
  }

  Future<Null> findLocation() async {
    location.onLocationChanged.listen((event) {
      lat1 = event.latitude;
      lng1 = event.longitude;
      // print('Lat1 = $lat1, Lng1 = $lng1');
      findLat1Lng1();
    });
  }

  Future<Null> findLat1Lng1() async {
    // LocationData locationData = await findLocationDate();
    setState(() {
      lat2 = restaurantModel.lat;
      lng2 = restaurantModel.lng;
      print('Lat1 = $lat1, Lng1 = $lng1, Lat2 = $lat2, Lng2 = $lng2');
      distance = MyAPI().calculateDistance(lat1, lng1, lat2, lng2);

      var myFormat = NumberFormat('##0.0#', 'en_US');
      distanceString = myFormat.format(distance);

      // transport = MyAPI().calculateTransport(distance);

      print('distance = $distance');
      // print('transport = $transport');
    });
  }

  Future<Null> readQueueData() async {
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidRes)
            .collection('restaurantQueueTable')
            .snapshots()
            .listen(
          (event) {
            for (var item in event.docs) {
              QueueModel model = QueueModel.fromMap(item.data());
              if (!model.queueStatus) {
                setState(() {
                  queueModel.add(model);
                });
                amount++;
              }

              // print('############## QueueModel $queueModel');
              print('Amount is $amount');
            }
          },
        );
      },
    );
  }

  Future<Null> readDataUidLogin() async {
    await Firebase.initializeApp().then(
      (value) async {
        FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            uidUser = event.uid;
            // print(uidUser);
            FirebaseFirestore.instance
                .collection('userTable')
                .doc(uidUser)
                .snapshots()
                .listen(
              (event) async {
                setState(
                  () {
                    userModel = UserModel.fromMap(
                      event.data(),
                    );
                    nameLogin = userModel.name;
                    urlImageUser = userModel.imageProfile;
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Null> findToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      token = value;
      print('############Token is $token ###############');
    });
  }

  @override
  Widget build(BuildContext context) {
    dateTimeNow = DateTime.now();
    screens = MediaQuery.of(context).size.width;
    // print('DateTime Now $now');
    date = dateFormat.format(dateTimeNow);
    time = timeFormat.format(dateTimeNow);

    // print('Date is $date');
    // print('Time is $time');
    // print('Uid User $uidUser');
    // print('Name Login is $nameLogin');
    // print('Uid Rest $uidRes');
    // print('Name Rest is ${restaurantModel.nameRes}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            size: 40,
          ),
        ),
        backgroundColor: Colors.red,
        title: Container(
          margin: EdgeInsets.only(right: 75),
          child: Center(
            child: Text('จองคิว'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // TextButton(
              //   onPressed: () {
              //     adddQueueAmount();
              //   },
              //   child: Text('AddQueueAmount'),
              // ),
              // showLogoApp(context),
              showCardRestaurant(context),
              distance == null
                  ? Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 150),
                        child: MyStyle().showProgress(),
                      ),
                    )
                  : distance <= 10
                      ? Column(
                          children: [
                            showTitle(), methodType2(),
                            methodType4(),
                            methodType6(), methodType8(),
                            // showTextNumberOfPeople(),
                            // textFieldNumberOfPeople(),
                            saveButton(),
                          ],
                        )
                      : Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 130),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              'ไม่สามารถจองคิวได้เนื่องจากคุณอยู่ห่างจากร้านเกิน 10 กิโลเมตร',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
            ],
          ),
        ),
      ),
    );
  }

  Container showLogoApp(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Image.asset('images/logo.png'),
    );
  }

  Container showCardRestaurant(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(10),
      height: 200,
      child: Card(
        shadowColor: Colors.red[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 180,
              // color: Colors.redAccent,
              width: MediaQuery.of(context).size.width * 0.4,
              child: Image.network(restaurantModel.urlImageRes),
            ),
            Container(
              height: 180,
              // color: Colors.redAccent,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        color: primaryColor,
                      ),
                      Text(
                        '  ${restaurantModel.nameRes}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        color: primaryColor,
                      ),
                      Container(
                        width: 155,
                        child: Text(
                          '  ${restaurantModel.address}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom,
                        color: primaryColor,
                      ),
                      Text(
                        '  รอ ${amount} คิว',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textFieldNumberOfPeople() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) => peopleAmount = value.trim(),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.person,
            color: Colors.red,
          ),
          label: Text(
            'จำนวนคน',
            style: TextStyle(color: Colors.black54),
          ),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget showTextNumberOfPeople() => Row(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 25,
              top: 15,
            ),
            child: Text(
              'กรุณากรอกจำนวนคนที่เข้าใช้บริการ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );

  Container methodType2() {
    return Container(
      width: screens * 0.6,
      child: Transform.scale(
        scale: 1.1,
        child: RadioListTile(
          activeColor: Colors.red,
          value: 'table2',
          groupValue: typeTable,
          onChanged: (value) {
            setState(() {
              typeTable = value;
            });
          },
          title: Text('โต๊ะสำหรับ 2 ท่าน'),
        ),
      ),
    );
  }

  Container methodType4() {
    return Container(
      width: screens * 0.6,
      child: Transform.scale(
        scale: 1.1,
        child: RadioListTile(
          activeColor: Colors.red,
          value: 'table4',
          groupValue: typeTable,
          onChanged: (value) {
            setState(() {
              typeTable = value;
            });
          },
          title: Text('โต๊ะสำหรับ 4 ท่าน'),
        ),
      ),
    );
  }

  Container methodType6() {
    return Container(
      width: screens * 0.6,
      child: Transform.scale(
        scale: 1.1,
        child: RadioListTile(
          activeColor: Colors.red,
          value: 'table6',
          groupValue: typeTable,
          onChanged: (value) {
            setState(() {
              typeTable = value;
            });
          },
          title: Text('โต๊ะสำหรับ 6 ท่าน'),
        ),
      ),
    );
  }

  Container methodType8() {
    return Container(
      width: screens * 0.6,
      child: Transform.scale(
        scale: 1.1,
        child: RadioListTile(
          activeColor: Colors.red,
          value: 'table8',
          groupValue: typeTable,
          onChanged: (value) {
            setState(() {
              typeTable = value;
            });
          },
          title: Text('โต๊ะสำหรับ 8 ท่าน'),
        ),
      ),
    );
  }

  Container showTitle() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: screens * 0.8,
      child: Text(
        'ประเภทโต๊ะ :',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 30),
      width: screens * 0.6,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if ((typeTable?.isEmpty ?? true)) {
            normalDialog(context, 'กรุณาเลือกประเภทโต๊ะ');
          } else {
            type();
            sentNotification();
            Navigator.pop(context);
          }
        },
        child: Text(
          'จองเลย !',
          style: TextStyle(fontSize: 20),
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
          .doc(uidRes)
          .collection('detailNotificationTable')
          .doc()
          .set(data)
          .then((value) {
        print('Add Notification to database success');
      });
    });
  }

  void type() {
    if (typeTable == 'table2') {
      peopleAmount = '2';
      addReceeiveQueue();
    } else if (typeTable == 'table4') {
      peopleAmount = '4';
      addReceeiveQueue();
    } else if (typeTable == 'table6') {
      peopleAmount = '6';
      addReceeiveQueue();
    } else if (typeTable == 'table8') {
      peopleAmount = '8';
      addReceeiveQueue();
    } else {
      print('No success');
    }
  }

  Future<Null> addReceeiveQueue() async {
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            String uidUser = event.uid;
            QueueModel queueModel = QueueModel(
              time: Timestamp.fromDate(dateTimeNow),
              peopleAmount: peopleAmount,
              nameRest: restaurantModel.nameRes,
              tableType: typeTable,
              uidUser: uidUser,
              nameUser: nameLogin,
              queueStatus: queueStatus,
              urlImageRest: restaurantModel.urlImageRes,
              uidRest: uidRes,
              urlImageUser: urlImageUser,
              address: restaurantModel.address,
              waitStatus: waitStatus,
              phoneRest: restaurantModel.phoneRest,
              phonrUser: userModel.phoneUser,
            );
            Map<String, dynamic> data = queueModel.toMap();
            await FirebaseFirestore.instance
                .collection('restaurantTable')
                .doc(uidRes)
                .collection('restaurantQueueTable')
                .doc()
                .set(data)
                .then(
              (value) {
                // sendNotication();
                // readDatailDesk();
                normalDialog(context, 'Succress');
              },
            );
          },
        );
      },
    );
  }
  Future<void> sentNotification() async {
    // print('You click $uidUser');

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('restaurantTable')
          .doc(uidRes)
          .get()
          .then((value) async {
        RestaurantModel restaurantModel = RestaurantModel.fromMap(value.data());
        String token = restaurantModel.token;
        // print('Token Is ====>>>> $token');

        this.title = 'คุณ $nameLogin';
        this.body = 'ได้ทำการจองคิวจากร้านของคุณ';

        var path =
            'https://www.androidthai.in.th/mea/bengapiNotification.php?isAdd=true&token=$token&title=$title&body=$body';

        await Dio().get(path).then((value) {
          print('Value ===>>> $value');
        });

        addDetailNotification();
      });
    });
  }

  void adddQueueAmount() {
    for (var i = 0; i < 1; i++) {
      if (queueAmount < 5) {
        setState(() {
          queueAmount++;
        });
      } else {
        queueAmount = 1;
      }
    }
    print('QueueAmout == $queueAmount');
    addReceeiveQueue();
  }
}
