import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_dashboard/config.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'Dashboard.dart';
import 'config.dart';

void main() => runApp(new signup());

class signup extends StatelessWidget {
  TextEditingController _username = TextEditingController();
  TextEditingController _fullName = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _email = TextEditingController();

  Future _onRegisterCloudMQTT() async {
    String url = 'https://api.cloudmqtt.com/api/user';
    Map map = {
      'username': 'zzz',
      'password': 'zzz',
      'authorization': config.basicAuth
    };

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(map)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    print(reply);
    // http.post('https://api.cloudmqtt.com/api/user',

    //     body: {"username": _username.text, "password": _password.text},
    //     headers: {"Content-Type":"application/json","authorization": config.basicAuth}).then((response) {
    //   print(response.body);
    // });
  }

  @override
  Widget build(BuildContext context) {
    void showToast(String msg, {int duration, int gravity}) {
      Toast.show(msg, context, duration: duration, gravity: gravity);
    }

    void onRegister() async {
      // bool check = _formKey.currentState.validate();
      if (true) {
        var uri = Uri.http('${config.API_Url}', '/api/user/register', {
          "username": _username.text,
          "pw": _password.text,
          "fullName": "benjawan komtabut"
        });
        var response = await http.get(uri, headers: {
          // HttpHeaders.authorizationHeader: 'Token $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        });
        print(response.body);
        Map jsonData = jsonDecode(response.body) as Map;

        if (jsonData['status'] == 0) {
          int userId = jsonData['data'];
          showToast("Register Success",
              duration: Toast.LENGTH_LONG, gravity: 0);
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (BuildContext context) => dashboard(userId)));
        } else {
          showToast("User Exit", duration: Toast.LENGTH_LONG, gravity: 0);
        }
      }
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "MQTT",
        theme: ThemeData(
          cursorColor: Colors.grey,
        ),
        home: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text('SIGN UP', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
            ),
            body: ListView(children: <Widget>[
              new Container(
                  padding: const EdgeInsets.all(20.0),
                  child: new Container(
                    child: new Center(
                      child: new Column(
                        children: [
                          new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextFormField(
                            controller: _username,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelText: 'USERNAME',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.account_box,
                                color: Colors.white70,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextFormField(
                            controller: _fullName,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelText: 'FULL NAME',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.account_box,
                                color: Colors.white70,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _password,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelText: 'PASSWORD',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.tealAccent,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelText: 'CONFIRM PASSWORD',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.vpn_key,
                                color: Colors.tealAccent,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          new Padding(padding: EdgeInsets.only(top: 20.0)),
                          ButtonTheme(
                            minWidth: 150.0,
                            height: 50.0,
                            child: RaisedButton(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                              ),
                              onPressed: onRegister,
                              child: Text("SIGN UP"),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            ])));
  }
}
