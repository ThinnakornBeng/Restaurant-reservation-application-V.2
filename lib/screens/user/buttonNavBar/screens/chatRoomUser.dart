import 'package:b_queue/model/queue_model.dart';
import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/utility/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatroomUser extends StatefulWidget {
  final QueueModel queueModel;
  final String chatRoomId;
  const ChatroomUser(
      {Key key, @required this.chatRoomId, @required this.queueModel})
      : super(key: key);

  @override
  _ChatroomUserState createState() => _ChatroomUserState();
}

class _ChatroomUserState extends State<ChatroomUser> {
  TextEditingController msg = new TextEditingController();
  QueueModel queueModel;
  String chatRoomId, title, body;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queueModel = widget.queueModel;
    chatRoomId = widget.chatRoomId;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor,
        title: Text('ร้าน ${queueModel.nameRest}'),
      ),
      body: Container(
        height: size.height / 1.25,
        width: size.width,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('chatroomTable')
              .doc(chatRoomId)
              .collection('chatTable')
              .orderBy('time', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> map = snapshot.data.docs[index].data();
                  return message(size, map);
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(left: 40, top: 100),
        height: size.height / 8,
        width: size.height,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: size.height / 10,
            width: size.height,
            child: TextField(
              controller: msg,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      onAddChatRoom();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.red,
                    )),
                hintText: 'กรุณากรอกข้อความที่ต้องการส่ง...',
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
          ),
        ),
      ),

      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   crossAxisAlignment: CrossAxisAlignment.stretch,
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(6.0),
      //       child: Text('Message'),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(16.0),
      //       child: Container(
      //         child: TextField(
      //           controller: msg,
      //           decoration: InputDecoration(
      //             hintText: 'Enter Message...',
      //             suffixIcon: IconButton(
      //               onPressed: () {
      //                 print(msg.text);
      //                 msg.clear();
      //               },
      //               icon: Icon(
      //                 Icons.send,
      //                 color: Colors.red,
      //               ),
      //             ),
      //             border: InputBorder.none,
      //             enabledBorder: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(10),
      //               borderSide: BorderSide(color: Colors.red),
      //             ),
      //             focusedBorder: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(10),
      //               borderSide: BorderSide(color: Colors.red),
      //             ),
      //           ),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
    );
  }

  Widget message(Size size, Map<String, dynamic> map) {
    return Container(
      width: size.width,
      alignment: map['sendby'] == queueModel.nameUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          map['message'],
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  void onAddChatRoom() async {
    Map<String, dynamic> chatRoomMap = {
      'name': queueModel.nameUser,
      'userProfile': queueModel.urlImageUser,
      'uidRest': queueModel.uidRest,
      // 'uidRest': queueModel.uidRest,
    };

    await FirebaseFirestore.instance
        .collection('chatroomTable')
        .doc(queueModel.uidUser)
        .set(chatRoomMap)
        .then((value) {
      print('Add Success');
    });
    onSentMessage();
    sentNotification();
  }

  void onSentMessage() async {
    if (msg.text.isNotEmpty) {
      Map<String, dynamic> message = {
        'sendby': queueModel.nameUser,
        'message': msg.text,
        'time': FieldValue.serverTimestamp(),
        // 'uidRest': queueModel.uidRest,
      };

      await _firestore
          .collection('chatroomTable')
          .doc(chatRoomId)
          .collection('chatTable')
          .add(message);
      msg.clear();
    } else {
      print("Enter Some Text");
    }
  }

  Future<void> sentNotification() async {
    // print('You click $uidUser');

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('restaurantTable')
          .doc(queueModel.uidRest)
          .get()
          .then((value) async {
        RestaurantModel restaurantModel = RestaurantModel.fromMap(value.data());
        String token = restaurantModel.token;
        // print('Token Is ====>>>> $token');

        this.title = 'ข้อความจากคุณ ${queueModel.nameUser}.';
        this.body = msg.text;

        var path =
            'https://www.androidthai.in.th/mea/bengapiNotification.php?isAdd=true&token=$token&title=$title&body=$body';

        await Dio().get(path).then((value) {
          print('Value ===>>> $value');
        });
      });
    });
  }
}
