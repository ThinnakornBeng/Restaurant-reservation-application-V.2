import 'dart:convert';

class ChatRoomModel {
  final String name;
  final String userProfile;
  final String uidRest;
  ChatRoomModel({
     this.name,
     this.userProfile,
     this.uidRest,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userProfile': userProfile,
      'uidRest': uidRest,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      name: map['name'] ?? '',
      userProfile: map['userProfile'] ?? '',
      uidRest: map['uidRest'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory ChatRoomModel.fromJson(String source) => ChatRoomModel.fromMap(json.decode(source));
}
