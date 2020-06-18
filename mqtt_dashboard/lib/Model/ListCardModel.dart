// To parse this JSON data, do
//
//     final welcome = welcomeFromMap(jsonString);

import 'dart:convert';

ListCardModel welcomeFromMap(String str) => ListCardModel.fromMap(json.decode(str));

String welcomeToMap(ListCardModel data) => json.encode(data.toMap());

class ListCardModel {
    ListCardModel({
        this.status,
        this.message,
        this.data,
    });

    int status;
    String message;
    List<ListCard> data;

    factory ListCardModel.fromMap(Map<String, dynamic> json) => ListCardModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : List<ListCard>.from(json["data"].map((x) => ListCard.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class ListCard {
    ListCard({
        this.id,
        this.userId,
        this.title,
        this.topic,
        this.onValue,
        this.offValue,
        this.dataNow,
    });

    int id;
    int userId;
    String title;
    String topic;
    String onValue;
    String offValue;
    String dataNow;

    factory ListCard.fromMap(Map<String, dynamic> json) => ListCard(
        id: json["id"] == null ? null : json["id"],
        userId: json["userId"] == null ? null : json["userId"],
        title: json["title"] == null ? null : json["title"],
        topic: json["topic"] == null ? null : json["topic"],
        onValue: json["onValue"] == null ? null : json["onValue"],
        offValue: json["offValue"] == null ? null : json["offValue"],
        dataNow: json["dataNow"] == null ? null : json["dataNow"],
    );

    Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "userId": userId == null ? null : userId,
        "title": title == null ? null : title,
        "topic": topic == null ? null : topic,
        "onValue": onValue == null ? null : onValue,
        "offValue": offValue == null ? null : offValue,
        "dataNow": dataNow == null ? null : dataNow,
    };
}
