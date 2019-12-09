import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Dashboard.dart';
import 'Signup.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    theme: ThemeData(
      cursorColor: Colors.grey,
    ),
  ));
}

class MyApp extends StatelessWidget {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(50.0),
            child: new Center(
              child: new Column(children: <Widget>[
                new Padding(padding: EdgeInsets.only(top: 110.0)),
                new Text(
                  'LOGO',
                  style: new TextStyle(color: Colors.grey[300], fontSize: 25.0),
                ),
                new Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.only(top: 50.0)),
                      new TextFormField(
                        controller: _username,
                        style: TextStyle(color: Colors.grey),
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.grey[300]),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        validator: (String value) {
                          return "กรุณากรอก username";
                        },
                      ),
                      new Padding(padding: EdgeInsets.only(top: 20.0)),
                      new TextFormField(       
                        controller: _password,
                        style: TextStyle(color: Colors.grey),
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[300]),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),                                                    
                        ),                          
                        validator: (String value) {
                          return "กรุณากรอก password";
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
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              dashboard({"temp": ""})));
                    },
                    child: Text("Login"),
                    color: Colors.grey[300],
                  ),
                ),
                new FlatButton(
                  child: Text(
                    'Forgot password',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  onPressed: connectAPI,
                ),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => signup()));
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(color: Colors.grey[300]),
                    ))
              ]),
            ),
          )
        ],
      ),
    );
  }
}
