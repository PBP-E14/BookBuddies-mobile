// To parse this JSON data, do
//
//     final checkSuperuser = checkSuperuserFromJson(jsonString);

import 'dart:convert';

CheckSuperuser checkSuperuserFromJson(String str) =>
    CheckSuperuser.fromJson(json.decode(str));

String checkSuperuserToJson(CheckSuperuser data) => json.encode(data.toJson());

class CheckSuperuser {
  bool isSuperuser;

  CheckSuperuser({
    required this.isSuperuser,
  });

  factory CheckSuperuser.fromJson(Map<String, dynamic> json) => CheckSuperuser(
        isSuperuser: json["is_superuser"],
      );

  Map<String, dynamic> toJson() => {
        "is_superuser": isSuperuser,
      };
}
