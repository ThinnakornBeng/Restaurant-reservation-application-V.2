import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/authtication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatUser1 extends StatefulWidget {
  const ChatUser1({Key key}) : super(key: key);

  @override
  State<ChatUser1> createState() => _ChatUser1State();
}

class _ChatUser1State extends State<ChatUser1> {
  TextEditingController msg = new TextEditingController();
  UserModel userModel;
  String uid;
  String chatRoomId = "bO7gkK9T5GPMuWAu2eEVDzRGt7q1";

  @override
  void initState() {
    super.initState();
    readUidLogin();
  }

  Future<Null> readUidLogin() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        uid = event.uid;
        // print('Uid = $uid');
        await FirebaseFirestore.instance
            .collection('userTable')
            .doc(uid)
            .snapshots()
            .listen((event) {
          setState(() {
            userModel = UserModel.fromMap(event.data());
            // String nameLogin = userModel.name;
            // print('NameLogin ====>>>> $nameLogin');
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.search_rounded),
        ),
        title: Text('Workshop ChatApp'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await Firebase.initializeApp().then(
                  (value) async {
                    await FirebaseAuth.instance.signOut().then(
                          (value) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Authentication(),
                              ),
                              (route) => false),
                        );
                  },
                );
              },
              icon: Icon(Icons.login_outlined))
        ],
      ),
      body: Container(
        height: size.height / 1.25,
        width: size.width,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
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
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
          controller: msg,
          decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () {
                    onSentMessage();
                  },
                  icon: Icon(
                    Icons.send,
                    color: Colors.blue,
                    size: 30,
                  )),
              hintText: 'กรุณากรอกข้อความ...',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.blue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.blue),
              )),
        ),
      ),
    );
  }

  // void onAddChatRoom() async {
  //   Map<String, dynamic> chatRoomMap = {
  //     'name': userModel.name,
  //     // 'uidRest': queueModel.uidRest,
  //   };

  //   await FirebaseFirestore.instance
  //       .collection('chatroomTable')
  //       .doc(chatRoomId)
  //       .set(chatRoomMap)
  //       .then((value) {
  //     print('Add Success');
  //   });
  //   onSentMessage();
  // }

  void onSentMessage() async {
    if (msg.text.isNotEmpty) {
      Map<String, dynamic> message = {
        'sendby': userModel.name,
        'message': msg.text,
        'time': FieldValue.serverTimestamp(),
        // 'uidRest': queueModel.uidRest,
      };

      await FirebaseFirestore.instance
          .collection('chatroomTable')
          .doc(chatRoomId)
          .collection('chatTable')
          .add(message);
      msg.clear();
    } else {
      print("Enter Some Text");
    }
  }

  Widget message(Size size, Map<String, dynamic> map) {
    return Container(
      width: size.width,
      alignment: map['sendby'] == userModel.name
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          map['message'],
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
