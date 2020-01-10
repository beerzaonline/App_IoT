import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'Dashboard.dart';
import 'Signup.dart';
import 'config.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: ThemeData(
      cursorColor: Colors.grey,
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  void initState() {
    _getUserId().then((id) {
      if (id != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => dashboard(id, null)));
      }
    });
    super.initState();
  }

  void connectAPI() {
    bool check = _formKey.currentState.validate();
    if (check) {
      String name = 'aaa';
      String username = '';
      String password = '2b6d43d7-8f77-40cb-b2b1-09ca97e25f8c';
      String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      Uri uri = Uri.parse('https://api.cloudmqtt.com/api/user/' + name);

      http.get(uri, headers: {"authorization": basicAuth}).then((response) {
        print(response.body);
      });
    }
  }

  _login(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("id", userId);
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("id", null);
  }

  Future<int> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int temp = await prefs.getInt("id");
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    void showToast(String msg,
        {int duration, int gravity, Color backgroundColor}) {
      Toast.show(msg, context,
          duration: duration,
          gravity: gravity,
          backgroundColor: backgroundColor);
    }

    void _onLogin() async {
      if (true) {
        var uri = Uri.http('${config.API_Url}', '/api/user/loginApp',
            {"username": _username.text, "password": _password.text});
        var response = await http.get(uri, headers: {
          // HttpHeaders.authorizationHeader: 'Token $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        });
        print(response.body);
        Map jsonData = jsonDecode(response.body) as Map;

        if (jsonData['status'] == 0) {
          int userId = jsonData['data'];
          _login(userId);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => dashboard(userId, null)));
        } else {
          showToast("Username Or Password Error",
              duration: Toast.LENGTH_LONG,
              gravity: 0,
              backgroundColor: Colors.white54);
        }
      }
    }

    DateTime currentBackPressTime;
    Future<bool> onWillPop() {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        showToast("Back Agian To Exit",
            duration: Toast.LENGTH_LONG,
            gravity: 0,
            backgroundColor: Colors.white54);
        return Future.value(false);
      }
      return Future.value(true);
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          backgroundColor: Colors.black,
          body: ListView(
              padding:
                  const EdgeInsets.only(left: 50.0, right: 50.0, top: 100.0),
              children: <Widget>[
                new Text(
                  'LOGIN',
                  textAlign: TextAlign.center,
                  style: new TextStyle(color: Colors.grey[300], fontSize: 25.0),
                ),
                new Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.only(top: 20.0)),
                      new TextFormField(
                        controller: _username,
                        style: TextStyle(color: Colors.grey),
                        decoration: new InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]),
                                borderRadius: BorderRadius.circular(5.0)),
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            // errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        validator: (String value) {
                          if (value.trim().isEmpty) {
                            return 'Please enter Username';
                          }
                        },
                      ),
                      new Padding(padding: EdgeInsets.only(top: 15.0)),
                      new TextFormField(
                        obscureText: true,
                        controller: _password,
                        style: TextStyle(color: Colors.grey),
                        decoration: new InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        validator: (String value) {
                          if (value.trim().isEmpty) {
                            return 'Please enter Password';
                          }
                        },
                      ),
                    ],
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
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _onLogin();
                      }
                    },
                    child: Text("Login"),
                    color: Colors.grey[300],
                  ),
                ),
                new FlatButton(
                  child: Text(
                    'Sign up',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  onPressed: () {
                    // if (_formKey.currentState.validate()) {
                    //   // Scaffold.of(context).showSnackBar(
                    //   //     SnackBar(content: Text('Processing Data')));
                    // }
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => signup()));
                  },
                )
              ])),
    );
  }
}
