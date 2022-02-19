import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DataBaseRestaurant {
  getRestaurantByNameRestaurant(String nameRest) async {
    return await Firebase.initializeApp().then((value) async {
      FirebaseFirestore.instance
          .collection('restaurantTable')
          .where('nameRes', isGreaterThanOrEqualTo: nameRest)
          .get();
    });
  }

  upLoadRestaurantInfo(restMapData) {
    FirebaseFirestore.instance.collection('restaurantTable').add(restMapData);
  }
}
