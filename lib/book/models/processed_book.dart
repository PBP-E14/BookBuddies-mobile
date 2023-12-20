// To parse this JSON data, do
//
//     final processedBook = processedBookFromJson(jsonString);

import 'dart:convert';

List<ProcessedBook> processedBookFromJson(String str) =>
    List<ProcessedBook>.from(
        json.decode(str).map((x) => ProcessedBook.fromJson(x)));

String processedBookToJson(List<ProcessedBook> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProcessedBook {
  String model;
  int pk;
  Fields fields;

  ProcessedBook({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory ProcessedBook.fromJson(Map<String, dynamic> json) => ProcessedBook(
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
  bool isRead;
  bool isWishlist;
  int wishlistPk;

  Fields({
    required this.title,
    required this.author,
    required this.publisher,
    required this.yearPublication,
    required this.imageCover,
    required this.isRead,
    required this.isWishlist,
    required this.wishlistPk,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        author: json["author"],
        publisher: json["publisher"],
        yearPublication: json["year_publication"],
        imageCover: json["image_cover"],
        isRead: json["isRead"],
        isWishlist: json["isWishlist"],
        wishlistPk: json["wishlistPk"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "author": author,
        "publisher": publisher,
        "year_publication": yearPublication,
        "image_cover": imageCover,
        "isRead": isRead,
        "isWishlist": isWishlist,
        "wishlistPk": wishlistPk,
      };
}
