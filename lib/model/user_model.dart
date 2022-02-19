import 'dart:convert';

class UserModel {
  final String name;
  final String email;
  final String userType;
  final String imageProfile;
  final String token;
  final String phoneUser;
  UserModel({
     this.name,
     this.email,
     this.userType,
     this.imageProfile,
     this.token,
     this.phoneUser,
  });
 

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userType': userType,
      'imageProfile': imageProfile,
      'token': token,
      'phoneUser': phoneUser,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userType: map['userType'] ?? '',
      imageProfile: map['imageProfile'] ?? '',
      token: map['token'] ?? '',
      phoneUser: map['phoneUser'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
