import 'dart:convert';

class DetailNotificationModel {
  final String title;
  final String body;
  DetailNotificationModel({
     this.title,
     this.body,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
    };
  }

  factory DetailNotificationModel.fromMap(Map<String, dynamic> map) {
    return DetailNotificationModel(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DetailNotificationModel.fromJson(String source) => DetailNotificationModel.fromMap(json.decode(source));
}
