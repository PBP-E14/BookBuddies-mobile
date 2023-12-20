// To parse this JSON data, do
//
//     final requestBook = requestBookFromJson(jsonString);

import 'dart:convert';

List<RequestBook> requestBookFromJson(String str) => List<RequestBook>.from(
    json.decode(str).map((x) => RequestBook.fromJson(x)));

String requestBookToJson(List<RequestBook> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RequestBook {
  String model;
  int pk;
  Fields fields;

  RequestBook({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory RequestBook.fromJson(Map<String, dynamic> json) => RequestBook(
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
  String author;
  String publisher;
  int yearPublication;
  String imageCover;
  bool isAccepted;
  int user;
  DateTime createdAt;

  Fields({
    required this.title,
    required this.author,
    required this.publisher,
    required this.yearPublication,
    required this.imageCover,
    required this.isAccepted,
    required this.user,
    required this.createdAt,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        author: json["author"],
        publisher: json["publisher"],
        yearPublication: json["year_publication"],
        imageCover: json["image_cover"],
        isAccepted: json["is_accepted"],
        user: json["user"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "author": author,
        "publisher": publisher,
        "year_publication": yearPublication,
        "image_cover": imageCover,
        "is_accepted": isAccepted,
        "user": user,
        "created_at": createdAt.toIso8601String(),
      };
}
