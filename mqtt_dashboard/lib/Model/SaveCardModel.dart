// To parse this JSON data, do
//
//     final welcome = welcomeFromMap(jsonString);

import 'dart:convert';

import 'package:mqtt_dashboard/Model/ListCardModel.dart';

SaveCardModel welcomeFromMap(String str) => SaveCardModel.fromMap(json.decode(str));

String welcomeToMap(SaveCardModel data) => json.encode(data.toMap());

class SaveCardModel {
    SaveCardModel({
        this.status,
        this.message,
        this.data,
    });

    int status;
    String message;
    ListCard data;

    factory SaveCardModel.fromMap(Map<String, dynamic> json) => SaveCardModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : ListCard.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data == null ? null : data.toMap(),
    };
}
