import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/chat_user_1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isLoading = false;
  TextEditingController _searchController = new TextEditingController();
  Map<String, dynamic> userMap;
  UserModel userModels;
  String uiduser;

  Future<void> onSearch() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        isLoading = true;
      });
    }

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('userTable')
          .where('name', isGreaterThanOrEqualTo: _searchController.text)
          .get()
          .then((value) {
        setState(() {
          if (_searchController.text.isEmpty) {
            print('null');
          } else {
            userMap = value.docs[0].data();
            isLoading = false;
          }
        });
        print(userMap);
        readRestaurantData();
      }).catchError((e) {
        print(e.toString());
      });
    });
  }

  Future<void> readRestaurantData() async {
    Firebase.initializeApp().then((value) async {
      FirebaseAuth.instance.authStateChanges().listen((event) async {
        FirebaseFirestore.instance
            .collection('userTable')
            .get()
            .then((value) async {
          for (var item in value.docs) {
            UserModel userModel = UserModel.fromMap(item.data());
            if (userModel.name == userMap['name']) {
              setState(() {
                uiduser = item.id;
                userModels = userModel;
              });
            }
            print(uiduser);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Page'),
        centerTitle: true,
      ),
      body: isLoading
          // ? MyStyle().showProgress()
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        suffixIcon: Container(
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(360),
                          //   color: Colors.grey[350],
                          // ),
                          margin: EdgeInsets.only(right: 15),
                          child: IconButton(
                            onPressed: () {
                              // onSearch();
                            },
                            icon: Icon(
                              Icons.search,
                              size: 35,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        hintText: 'กรุณากรอกชื่อร้านที่ต้องการค้นหา',
                        hintStyle: TextStyle(),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        onSearch();
                      });
                    },
                    child: Text(
                      'ค้นหา',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Expanded(
                    child: Center(
                        child:
                            Container(child: Center(child: Text('No data')))))
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        suffixIcon: Container(
                          margin: EdgeInsets.only(right: 15),
                          child: IconButton(
                            onPressed: () {
                              // setState(() {
                              //   onSearch();
                              // });
                            },
                            icon: Icon(
                              Icons.search,
                              size: 35,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        hintText: 'กรุณากรอกชื่อร้านที่ต้องการค้นหา',
                        hintStyle: TextStyle(),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                    onPressed: () {
                      setState(() {
                        onSearch();
                      });
                    },
                    child: Text(
                      'ค้นหา',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Expanded(
                    child: Column(
                  children: [
                    userMap != null
                        ? GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => AddQueueUser(
                              //               model: restaurantModels,
                              //               uidRest: uidRest,
                              //             )));
                            },
                            child: ListTile(
                              title: Text(userMap['name']),
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatUser1(),
                                      ));
                                },
                                icon: Icon(
                                  Icons.message_sharp,
                                  size: 35,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          )
                        : Center(),
                  ],
                )),
              ],
            ),
    );
  }
}
