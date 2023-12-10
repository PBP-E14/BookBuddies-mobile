// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<User> userFromJson(String str) => List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
    String model;
    int pk;
    Fields fields;

    User({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory User.fromJson(Map<String, dynamic> json) {
        print("Parsing User: $json");
        var user = User(
            model: json["model"],
            pk: json["pk"],
            fields: Fields.fromJson(json["fields"]),
        );
        print("Parsed User: ${user.toJson()}");
        return user;
    }

    // factory User.fromJson(Map<String, dynamic> json) => User(
    //     model: json["model"],
    //     pk: json["pk"],
    //     fields: Fields.fromJson(json["fields"]),
    // );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String username;
    String email;
    String gender;
    DateTime? birthDate;
    String phoneNumber;
    String address;
    String bio;
    List<int>? historyBooks;

    Fields({
        required this.username,
        required this.email,
        required this.gender,
        this.birthDate,
        required this.phoneNumber,
        required this.address,
        required this.bio,
        this.historyBooks,
    });

    factory Fields.fromJson(Map<String, dynamic> json) {
        print("Parsing Fields: $json");

        // Create the fields object
        var fields = Fields(
            username: json["username"],
            email: json["email"],
            gender: json["gender"],
            birthDate: json["birth_date"] == null ? null : DateTime.parse(json["birth_date"]),
            phoneNumber: json["phone_number"],
            address: json["address"],
            bio: json["bio"],
            historyBooks: List<int>.from(json["history_books"].map((x) => x)),
        );

        print("Parsed Fields: ${fields.toJson()}");
        return fields;
    }

  //   factory Fields.fromJson(Map<String, dynamic> json) => Fields(
  //     username: json["username"],
  //     email: json["email"],
  //     gender: json["gender"],
  //     birthDate: json["birth_date"] == null ? null : DateTime.parse(json["birth_date"]),
  //     phoneNumber: json["phone_number"],
  //     address: json["address"],
  //     bio: json["bio"],
  //     historyBooks: List<int>.from(json["history_books"].map((x) => x)),
  // );

    Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "gender": gender,
        "birth_date": birthDate == null ? null : 
                  "${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}",        "phone_number": phoneNumber,
        "address": address,
        "bio": bio,
        "history_books": historyBooks!.isNotEmpty ? 
                     List<dynamic>.from(historyBooks!.map((x) => x)) : [],
    };
}
