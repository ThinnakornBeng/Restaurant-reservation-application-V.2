import 'package:b_queue/database_rest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SearchTest extends StatefulWidget {
  const SearchTest({Key key}) : super(key: key);

  @override
  _SearchTestState createState() => _SearchTestState();
}

class _SearchTestState extends State<SearchTest> {
  bool isLoading = false;
  TextEditingController _search = new TextEditingController();
  DataBaseRestaurant dataBaseRestaurant = new DataBaseRestaurant();

  void onSearch() async {
    Map<String, dynamic> restaurant;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    Firebase.initializeApp().then((value) async {
      await firestore
          .collection('userTable')
          .where('email', isEqualTo: _search.text.toLowerCase())
          .get()
          .then((value) {
        setState(() {
          restaurant = value.docs[0].data();
          isLoading = false;
        });
        print(restaurant);
      }).catchError((e) {
        print(e.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Test'),
      ),
      body: isLoading
          ? Center(
              child: Container(
                width: size.height / 20,
                height: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                          hintText: 'Search',
                          // prefixIcon: Icon(Icons.search),
                          suffixIcon: Icon(Icons.search)),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSearch();
                    dataBaseRestaurant
                        .getRestaurantByNameRestaurant(_search.text)
                        .toString();
                  },
                  child: Text('Search'),
                ),
              ],
            ),
    );
  }
}
