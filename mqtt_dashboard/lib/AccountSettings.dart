import 'package:flutter/material.dart';

void main() => runApp(new accountSettings());

class accountSettings extends StatelessWidget {
  TextEditingController _newemail = TextEditingController();
  TextEditingController _confirmemail = TextEditingController();
  TextEditingController _newpass = TextEditingController();
  TextEditingController _confirmpass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "MQTT",
        theme: ThemeData(
          cursorColor: Colors.grey,
        ),
        home: Scaffold(
          backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text('Account Settings',style: TextStyle(color: Colors.grey[300])),
              backgroundColor: Colors.black,
            ),
            body: ListView(              
              children: <Widget>[
              new Container(
                  padding: const EdgeInsets.all(20.0),
                  child: new Container(
                    child: new Center(
                      child: new Column(
                        children: [
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextFormField(
                            controller: _newemail,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'New Email',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.mail,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _confirmemail,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Confirm New Email',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.drafts,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _newpass,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'New Password',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _confirmpass,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Confirm New Password',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.vpn_key,
                                color: Colors.white,
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
                              onPressed: () {},
                              child: Text("Save Change"),
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            ])));
  }
}
