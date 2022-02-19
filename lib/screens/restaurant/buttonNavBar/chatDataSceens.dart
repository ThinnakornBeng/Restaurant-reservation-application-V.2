import 'package:b_queue/model/chatroom_model.dart';
import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/restaurant/screens/chatRestaurant.dart';
import 'package:b_queue/utility/colors.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatSceens extends StatefulWidget {
  const ChatSceens({Key key}) : super(key: key);

  @override
  _ChatSceensState createState() => _ChatSceensState();
}

class _ChatSceensState extends State<ChatSceens> {
  List<Map<String, dynamic>> chatRoomMap;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChatRoomModel> chatRoomModels = [];
  String chatRoomId;
  RestaurantModel restaurantModel;
  String uidUser;
  UserModel userModel;
  List<String> uidChatRoom = [];

  Future<void> readChatRoomData() async {
    Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        chatRoomId = event.uid;
        await _firestore.collection('chatroomTable').snapshots().listen(
          (value) async {
            for (var item in value.docs) {
              String uirCR = item.id;
              uidChatRoom.add(uirCR);
              ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(item.data());
              if (chatRoomModel.uidRest == uidUser) {
                setState(() {
                  chatRoomModels.add(chatRoomModel);
                });
                print('Chatroom Id $uidChatRoom');
              }
            }
            // print(chatRoomModels);
          },
        );
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readChatRoomData();
    readDataLoginAndDatarestaurant();
  }

  Future<void> readDataLoginAndDatarestaurant() async {
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            uidUser = event.uid;
            // print('Uid = $uidUser');
            await FirebaseFirestore.instance
                .collection('userTable')
                .doc(uidUser)
                .snapshots()
                .listen(
              (event) {
                setState(
                  () {
                    userModel = UserModel.fromMap(event.data());
                    String nameLogin = userModel.name;
                    // print('NameLogin ====>>>> $nameLogin');
                  },
                );
              },
            );
            await FirebaseFirestore.instance
                .collection('restaurantTable')
                .doc(uidUser)
                .snapshots()
                .listen(
              (event) async {
                setState(() {
                  restaurantModel = RestaurantModel.fromMap(event.data());
                });
                // print(restaurantModel);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: chatRoomModels.isEmpty
          ? chatRoomModels.isNotEmpty
              ? MyStyle().showProgress()
              : Center(
                  child: Container(
                    child: Text('No Message'),
                  ),
                )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'ข้อความของฉัน',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: chatRoomModels.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatroomRestaurant(
                                  chatRoomId: uidChatRoom[index],
                                  restaurantModel: restaurantModel,
                                  chatRoomModel: chatRoomModels[index],
                                ),
                              ));
                        },
                        child: Card(
                            child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: ClipOval(
                                    child: Image.network(
                                        chatRoomModels[index].userProfile)),
                              ),
                            ),
                            Container(
                              // color: Colors.amber,
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                  "คุณ ${chatRoomModels[index].name} ได้ส่งข้อความถึงร้านของคุณ"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.11,
                                height: 70,
                                // color: Colors.blue,
                                child: Center(
                                  child: Icon(
                                    Icons.chat_bubble,
                                    size: 30,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )), 
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
