import 'package:b_queue/model/restaurant_model.dart';
import 'package:b_queue/screens/user/buttonNavBar/screens/addQueueUser.dart';
import 'package:b_queue/utility/colors.dart';
import 'package:b_queue/utility/my_api_location.dart';
import 'package:b_queue/utility/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({Key key}) : super(key: key);

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  List<RestaurantModel> restaurantModel = [];
  List<Widget> widgets = [];
  List<String> uidRests = [];
  List<String> idRest = [];
  double sceens;
  String urlImageUser;
  RestaurantModel remo;

  double lat1, lng1, distance;
  String distanceString;
  int transport;
  Location location = Location();
  int index = 0;
  double lat2 = 13.8180467, lng2 = 100.569405;
  Map<double, dynamic> lat3, lng3;
  List restaurantAll = [];
  var restaurantModels = <RestaurantModel>[];
  var statusLoad = true;
  var statusHaveData = false;
  // double lat2, lng2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readRestaurantData();
    // readData();
    // readDataLatLng();
    // readDetaiNotification();
    findLocation();
  }

  Future<void> readRestaurantData() async {
    Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('restaurantTable')
          .snapshots()
          .listen((event) async {
        for (var item in event.docs) {
          idRest.add(item.id);
          RestaurantModel rm = RestaurantModel.fromMap(item.data());
          setState(() {
            restaurantModels.add(rm);
          });
        }
      });
    });
  }

  Future<void> readDetaiNotification() async {
    if (restaurantModels.isEmpty) {
      restaurantModels.clear();
    }
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        await FirebaseFirestore.instance
            .collection('restaurantTable')
            .get()
            .then((value) {
          setState(() {
            statusLoad = false;
          });
          for (var item in value.docs) {
            RestaurantModel restModel = RestaurantModel.fromMap(item.data());
            double lat3 = restModel.lat;
            double lng3 = restModel.lng;
            print(lat3);
            print(lng3);

            restaurantModel.add(restModel);

            setState(() {
              statusHaveData = true;
              restaurantModels.add(restModel);
            });
          }
        });
      });
    });
  }

  Future<void> readDataLatLng() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('restaurantTable')
          .get()
          .then((value) {
        for (var item in value.docs) {
          remo = item['lat'];
        }

        print(remo);
      });
    });
  }

  Future<Null> findLocation() async {
    location.onLocationChanged.listen((event) {
      lat1 = event.latitude;
      lng1 = event.longitude;
      // print('Lat1 = $lat1, Lng1 = $lng1');

      findLat1Lng1();
    });
  }

  // Future<LocationData> findLocationDate() async {
  //   Location location = Location();
  //   try {
  //     return await location.getLocation();
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // Future<Null> readData() async {
  //   await Firebase.initializeApp().then(
  //     (value) async {
  //       await FirebaseFirestore.instance
  //           .collection('restaurantTable')
  //           .snapshots()
  //           .listen(
  //         (event) {
  //           for (var item in event.docs) {
  //             String uidRest = item.id;
  //             uidRests.add(uidRest);

  //             // print('Uid uidRestaurant is ===>>> $uidRests');
  //             RestaurantModel model = RestaurantModel.fromMap(item.data());
  //             restaurantModel.add(model);

  //             // print('NameRestaurant is ===>>> ${model.nameRes}');
  //             // print('Adderss  is ===>>> ${model.address}');
  //             // print('UrlPicture is ===>>> ${model.urlImageRes}');
  //             setState(
  //               () {
  //                 widgets.add(creatWidget(model, index));
  //               },
  //             );
  //             index++;
  //             // findLat1Lng1();
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

  Future<Null> findLat1Lng1() async {
    // LocationData locationData = await findLocationDate();
    setState(() {
      // lat1 = locationData.latitude;
      // lng1 = locationData.longitude;
      // lat2 = double.parse(restaurantModels[index].lat);
      // lng2 = double.parse(restaurantModels[index].lng);
      print('Lat1 = $lat1, Lng1 = $lng1, Lat2 = $lat2, Lng2 = $lng2');
      distance = MyAPI().calculateDistance(lat1, lng1, lat2, lng2);

      var myFormat = NumberFormat('##0.0#', 'en_US');
      distanceString = myFormat.format(distance);

      // transport = MyAPI().calculateTransport(distance);

      print('distance = $distance');
      // print('transport = $transport');
    });
  }

  @override
  Widget build(BuildContext context) {
    sceens = MediaQuery.of(context).size.width;
    return Scaffold(
        body: restaurantModels.isEmpty
            ? MyStyle().showProgress()
            // : Container(
            //     margin: EdgeInsets.only(left: 15, top: 10, right: 15),
            //     child: GridView.extent(
            //       maxCrossAxisExtent: 220,
            //       children: widgets,
            //     ),
            //   ),
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: restaurantModels.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddQueueUser(
                              model: restaurantModels[index],
                              uidRest: idRest[index],
                            ),
                          ));
                    },
                    child: Card(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 130,
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Image.network(
                                  restaurantModels[index].urlImageRes),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.green,
                              child: Column(
                                children: [],
                              ),
                            ),
                          ),
                          Container(
                            height: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_rounded,
                                        size: 30,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.37,
                                        child: Text(
                                          ' ${restaurantModels[index].nameRes}',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.place_rounded,
                                        size: 30,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.37,
                                        child: Text(
                                          ' ${restaurantModels[index].address}',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // Container(
                                //   width: MediaQuery.of(context).size.width * 0.45,
                                //   child: Row(
                                //     children: [
                                //       Icon(
                                //         Icons.ac_unit,
                                //         size: 30,
                                //         color: primaryColor,
                                //       ),
                                //       Container(
                                //         width: MediaQuery.of(context).size.width *
                                //             0.37,
                                //         child: Text('รอคิว 0'),
                                //       )
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  Widget creatWidget(RestaurantModel model, int index) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddQueueUser(
                model: restaurantModel[index],
                uidRest: uidRests[index],
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(5),
          child: Card(
            shadowColor: Colors.red[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showImage(model),
                showTextname(model),
              ],
            ),
          ),
        ),
      );
  void lat(RestaurantModel model) => Column(
        children: [
          Text("${model.lat}"),
        ],
      );
  void lng(RestaurantModel model) => Column(
        children: [
          Text("${model.lng}"),
        ],
      );

  Widget showTextname(RestaurantModel model) => Text(
        model.nameRes,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      );

  Widget showImage(RestaurantModel model) => Center(
        child: Card(
          color: Colors.red[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: ClipOval(
            child: Image.network(
              model.urlImageRes,
              fit: BoxFit.fill,
              width: sceens * 0.30,
              height: sceens * 0.30,
            ),
          ),
        ),
      );
}
