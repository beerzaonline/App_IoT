// To parse this JSON data, do
//
//     final welcome = welcomeFromMap(jsonString);

import 'dart:convert';

LoginModel welcomeFromMap(String str) => LoginModel.fromMap(json.decode(str));

String welcomeToMap(LoginModel data) => json.encode(data.toMap());

class LoginModel {
    LoginModel({
        this.status,
        this.message,
        this.data,
    });

    int status;
    String message;
    int data;

    factory LoginModel.fromMap(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data,
    };
}
