// To parse this JSON data, do
//
//     final forum = forumFromJson(jsonString);

import 'dart:convert';

List<Forum> forumFromJson(String str) => List<Forum>.from(json.decode(str).map((x) => Forum.fromJson(x)));

String forumToJson(List<Forum> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Forum {
  String model;
  int pk;
  Fields fields;

  Forum({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Forum.fromJson(Map<String, dynamic> json) => Forum(
    model: json["model"],
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  Map<String, dynamic> toJson() => {
    "model": model,
    "pk": pk,
    "fields": fields.toJson(),
  };
}

class Fields {
  String title;
  String content;
  int user;
  DateTime createdAt;
  int totalReply;

  Fields({
    required this.title,
    required this.content,
    required this.user,
    required this.createdAt,
    required this.totalReply,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    title: json["title"],
    content: json["content"],
    user: json["user"],
    createdAt: DateTime.parse(json["created_at"]),
    totalReply: json["total_reply"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
    "user": user,
    "created_at": "${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}",
    "total_reply": totalReply,
  };
}