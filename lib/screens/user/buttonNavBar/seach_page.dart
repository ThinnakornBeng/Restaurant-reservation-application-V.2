import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/addQueueUser.dart';
import 'package:b_queue/utility/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// class QrCodeUser extends StatefulWidget {
//   const QrCodeUser({Key key}) : super(key: key);

//   @override
//   _QrCodeUserState createState() => _QrCodeUserState();
// }

// class _QrCodeUserState extends State<QrCodeUser> {
//   String scanResults = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             TextButton(
//               onPressed: () async {
//                 scanResults = await RawScanner.scanCode(
//                     typeOfCode: BarcodeFormat.qrcode, context: context);
//                 // RawScanner.scanCode(
//                 //   typeOfCode:BarcodeFormat.qrcode,
//                 //   context: context,
//                 //   foregroundColor: Colors.black,
//                 //   backgroundColor: Colors.cyan,
//                 // );
//                 print(scanResults);
//                 if (scanResults != null) {
//                   setState(() {
//                     scanResults = scanResults;
//                   });
//                 }
//               },
//               child: Text(
//                 "Scan",
//               ),
//             ),
//             RawScanner.generateQrCode(scanResults),
//           ],
//         ),
//       ),
//     );
//   }
// }

class Search extends StatefulWidget {
  const Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool isLoading = false;
  TextEditingController _searchController = new TextEditingController();
  Map<String, dynamic> restaurantMap;
  RestaurantModel restaurantModels;
  String uidRest;

  Future<void> onSearch() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        isLoading = true;
      });
    }

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('restaurantTable')
          .where('nameRes', isGreaterThanOrEqualTo: _searchController.text)
          .get()
          .then((value) {
        setState(() {
          if (_searchController.text.isEmpty) {
            print('null');
          } else {
            restaurantMap = value.docs[0].data();
            isLoading = false;
          }
        });
        print(restaurantMap);
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
            .collection('restaurantTable')
            .get()
            .then((value) async {
          for (var item in value.docs) {
            RestaurantModel restaurantModel =
                RestaurantModel.fromMap(item.data());
            if (restaurantModel.nameRes == restaurantMap['nameRes']) {
              setState(() {
                uidRest = item.id;
                restaurantModels = restaurantModel;
              });
            }
            print(uidRest);
          }
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  // Widget searchList() {
  //   return ListView.builder(
  //     itemCount: restaurantMap.length,
  //     itemBuilder: (context, index) {
  //       return SearchTile(nameRest: '', address: '', urlImageRest: '');
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Search Store'),
      // ),
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
                              color:primaryColor,
                            ),
                          ),
                        ),
                        hintText: 'กรุณากรอกชื่อร้านที่ต้องการค้นหา',
                        hintStyle: TextStyle(),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
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
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(360),
                          //   color: Colors.grey[350],
                          // ),
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
                              color: primaryColor,
                            ),
                          ),
                        ),
                        hintText: 'กรุณากรอกชื่อร้านที่ต้องการค้นหา',
                        hintStyle: TextStyle(),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primaryColor),
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
                    restaurantMap != null
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddQueueUser(
                                            model: restaurantModels,
                                            uidRest: uidRest,
                                          )));
                            },
                            child: ListTile(
                              leading: Container(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                  restaurantMap['urlImageRes'],
                                ),
                              ),
                              title: Text(restaurantMap['nameRes']),
                              subtitle: Text(
                                restaurantMap['address'],
                              ),
                              // trailing: IconButton(
                              //   onPressed: () {Navigator.push(context, materpr)},
                              //   icon: Icon(
                              //     Icons.message_sharp,
                              //     size: 35,
                              //     color: Colors.redAccent,
                              //   ),
                              // ),
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

// class SearchTile extends StatelessWidget {
//   final String nameRest;
//   final String address;
//   final String urlImageRest;
//   const SearchTile({
//     Key key,
//     @required this.nameRest,
//     @required this.address,
//     @required this.urlImageRest,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Row(
//         children: [
//           Container(
//             width: 150,
//             height: 150,
//             child: Image.network(urlImageRest),
//           ),
//           Text(nameRest),
//           Text(address),
//         ],
//       ),
//     );
//   }
// }
