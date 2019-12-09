import 'package:flutter/material.dart';

void main() => runApp(new addTimepicker());

class addTimepicker extends StatelessWidget {
  TextEditingController _tname = TextEditingController();
  TextEditingController _ttopic = TextEditingController();
  TextEditingController _ttexton = TextEditingController();
  TextEditingController _ttextoff = TextEditingController();
  TextEditingController _tpublishon = TextEditingController();
  TextEditingController _tpublishoff = TextEditingController();
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
              title: Text('Publish : Timepicker',
                  style: TextStyle(color: Colors.grey[300])),
              backgroundColor: Colors.black,
            ),
            body: ListView(children: <Widget>[
              new Container(
                  padding: const EdgeInsets.all(20.0),
                  child: new Container(
                    child: new Center(
                      child: new Column(
                        children: [
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextFormField(
                            controller: _tname,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.create,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _ttopic,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                             focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Topic',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.account_balance,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          //  new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _ttexton,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Text (On)',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.settings_input_component,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _ttextoff,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Text (Off)',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.portrait,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          // new Padding(padding: EdgeInsets.only(top: 10.0)),
                          new TextField(
                            controller: _tpublishon,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                             focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Publish value (On)',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          new TextField(
                            controller: _tpublishoff,
                            style: TextStyle(color: Colors.white),
                            decoration: new InputDecoration(
                             focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Publish value (Off)',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
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
                              child: Text("Save"),
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