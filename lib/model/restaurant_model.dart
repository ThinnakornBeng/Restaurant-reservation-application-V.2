import 'dart:convert';

class RestaurantModel {
  final String nameRes;
  final String urlImageRes;
  final String address;
  final String token;
  final double lat;
  final double lng;
  final String phoneRest;
  RestaurantModel({
     this.nameRes,
     this.urlImageRes,
     this.address,
     this.token,
     this.lat,
     this.lng,
     this.phoneRest,
  });
  

  Map<String, dynamic> toMap() {
    return {
      'nameRes': nameRes,
      'urlImageRes': urlImageRes,
      'address': address,
      'token': token,
      'lat': lat,
      'lng': lng,
      'phoneRest': phoneRest,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      nameRes: map['nameRes'] ?? '',
      urlImageRes: map['urlImageRes'] ?? '',
      address: map['address'] ?? '',
      token: map['token'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      phoneRest: map['phoneRest'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantModel.fromJson(String source) => RestaurantModel.fromMap(json.decode(source));
}
