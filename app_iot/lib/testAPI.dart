import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
      home: TestAPI(),
    ));

class TestAPI extends StatelessWidget {
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  void _onPressed() {
    String username = '';
    String password = '2b6d43d7-8f77-40cb-b2b1-09ca97e25f8c';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    var data = {"username": _username.text, "password": _password.text};
    var json = jsonEncode(data);
    http.post('https://api.cloudmqtt.com/api/user',
        body: json,
        headers: <String, String>{
          "Content-Type": "application/json",
          "authorization": basicAuth
        }).then((response) {
      if (response.statusCode == 204) {
        print("สำเร็จ");
      }
    });
  }

  void _onShowInfo() {
    String username = '';
    String password = '2b6d43d7-8f77-40cb-b2b1-09ca97e25f8c';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    String _user = 'bbb';
    Uri uri = Uri.parse('https://api.cloudmqtt.com/api/user/' + _user);
    http.get(uri, headers: <String, String>{"authorization": basicAuth}).then(
        (response) {
      print(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("API"),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          TextField(
            controller: _username,
            decoration: InputDecoration(hintText: "username"),
          ),
          TextField(
            controller: _password,
            decoration: InputDecoration(hintText: "password"),
          ),
          RaisedButton(
            onPressed: _onPressed,
            child: Text("OK"),
          ),
          RaisedButton(
            onPressed: _onShowInfo,
            child: Text("Show"),
          )
        ],
      ),
    );
  }
}
