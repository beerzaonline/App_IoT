import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mqtt_dashboard/GetResponses.dart';
import 'Connection.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:http/http.dart' as http;
import 'config.dart';

import 'package:mqtt_dashboard/tempSwitch.dart';

import 'AccountSettings.dart';

List _temp = List();
TextEditingController _sName = TextEditingController();
TextEditingController _sTopic = TextEditingController();
TextEditingController _sTextOn = TextEditingController();
TextEditingController _sTextOff = TextEditingController();
TextEditingController _sPublishOn = TextEditingController();
TextEditingController _sPublishOff = TextEditingController();

TextEditingController _bName = TextEditingController();
TextEditingController _bTopic = TextEditingController();
TextEditingController _bTextOn = TextEditingController();
TextEditingController _bTextOff = TextEditingController();
TextEditingController _bPublishOn = TextEditingController();
TextEditingController _bPublishOff = TextEditingController();

class dashboard extends StatefulWidget {
  int _userId;
  mqtt.MqttClient _client;
  dashboard(this._userId, this._client);
  //print(_temp.length);

  @override
  State<StatefulWidget> createState() {
    return _dashboard(_userId, _client);
  }
}

// _incrementCounter() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   int counter = (prefs.getInt('counter') ?? 0) + 1;
//   print('Pressed $counter times.');
//   await prefs.setInt('counter', counter);
// }

class _dashboard extends State {
  int _userId;
  mqtt.MqttClient _client;
  _dashboard(this._userId, this._client);

  List lst = List();
  int count = 0;

  @override
  void initState() {
    this._listCard();
    super.initState();
  }

  void _onSwitchSave() async {
    var uri = Uri.http('${config.API_Url}', '/api/card/save', {
      "userId": _userId.toString(),
      "title": _sName.text,
      "topic": _sTopic.text,
      "onValue": _sPublishOn.text,
      "offValue": _sPublishOff.text
    });
    var response = await http.get(uri, headers: {
      // HttpHeaders.authorizationHeader: 'Token $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    Map jsonData = jsonDecode(response.body) as Map;

    if (jsonData['status'] == 0) {
      // int userId = jsonData['data'];
      Navigator.pop(context);
      Navigator.pop(context);
      setState(() {
        lst.clear();
        this._listCard();
      });
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (BuildContext context) => dashboard(userId, null)));
    } else {
      // showToast("Username Or Password Error",
      //     duration: Toast.LENGTH_LONG,
      //     gravity: 0,
      //     backgroundColor: Colors.white54);
    }
  }

  void _listCard() async {
    var uri = Uri.http('${config.API_Url}', '/api/card/list', {
      "userId": _userId.toString(),
    });
    var response = await http.get(uri, headers: {
      // HttpHeaders.authorizationHeader: 'Token $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    print(response.body);
    Map jsonData = jsonDecode(response.body) as Map;

    if (jsonData['status'] == 0) {
      List temp = jsonData['data'];
      for (var i = 0; i < temp.length; i++) {
        Map<String, dynamic> data = temp[i];
        _bodySwitch(data);
      }
      // int userId = jsonData['data'];
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (BuildContext context) => dashboard(userId, null)));

    } else {
      // showToast("Username Or Password Error",
      //     duration: Toast.LENGTH_LONG,
      //     gravity: 0,
      //     backgroundColor: Colors.white54);
    }
  }

//card Switch

  void _bodySwitch(Map<String, dynamic> data) {
    String _name = _sName.text;
    String _valueOn = _sTextOn.text;
    String _valueOff = _sTextOff.text;

    Card bt = Card(
      child: ListTile(
        onLongPress: () {
          _menu(context, data['id']);
        },
        title: Text(data['title']),
        // leading: Text(''),
        subtitle: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text('${data['id']}'),
            Padding(
              padding: EdgeInsets.only(right: 10),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                MdiIcons.toggleSwitchOff,
                size: 40,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            new Text('OFF'),
            Padding(
              padding: EdgeInsets.only(right: 10),
            ),
          ],
        ),
        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: <Widget>[
        //     FlatButton(
        //       onPressed: _delete,
        //       child: Icon(MdiIcons.delete),
        //     ),
        //   ],
        // )
      ),
    );

    setState(() {
      lst.add(bt);
    });
  }

//card Button

  void _bodyButton() {
    String _name = _bName.text;
    String _valueOn = _bTextOn.text;
    String _valueOff = _bTextOff.text;
    Card bt = Card(
      child: ListTile(
        title: Text(_name),
        leading: Text(''),
        subtitle: RaisedButton(
          child: Text('$_valueOn'),
          onPressed: () {},
        ),
        trailing: FlatButton(
          onPressed: () {},
          child: Icon(MdiIcons.delete),
        ),
      ),
    );
    setState(() {
      lst.add(bt);
    });
  }

//popup menu
  Future _menu(BuildContext context, int idCard) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {},
                child: Row(
                  children: <Widget>[
                    // SizedBox(width: 300),
                    Icon(Icons.create),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Edit'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  GetResponses obj = GetResponses();
                  Map res = await obj.Get(
                      url: "/api/card/delete",
                      body: {"idCard": idCard.toString()});
                  if (res['status'] == 0) {
                    Navigator.pop(context);
                    setState(() {
                      lst.clear();
                      this._listCard();
                    });
                  } else {}
                },
                child: Row(
                  children: <Widget>[
                    Icon(MdiIcons.delete),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
          );
        });
  }

// popup Select Component

  Future _asyncSimpleDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            titlePadding: EdgeInsets.fromLTRB(15.0, 24.0, 24.0, 0.0),
            contentPadding: EdgeInsets.fromLTRB(0, 10.0, 12.0, 16.0),
            title: const Text('Select Component'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  _dialogButton(context);
                  _bName.clear();
                  _bTopic.clear();
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => addButton()));
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.touch_app),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Button'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  _dialogSwtich(context);

                  // _dialogTimepicker(context);
                  // _sName.clear();
                  // _sTopic.clear();

                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => addSwitch()));
                },
                child: Row(
                  children: <Widget>[
                    Icon(MdiIcons.toggleSwitch),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('Switch'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => addTimepicker()));
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.av_timer),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    const Text('TimePicker'),
                  ],
                ),
              ),
            ],
          );
        });
  }

//_dialogButton

  Future<Null> _dialogButton(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Button'),
        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 8),
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _bName,
                  decoration: InputDecoration(
                    labelText: "Name",
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _bTopic,
                  decoration: InputDecoration(
                    labelText: "Topic",
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                new Padding(padding: EdgeInsets.only(top: 8.0)),
                RaisedButton(
                  child: Text('ok'),
                  onPressed: () {
                    _bodyButton();
                    _bName.clear();
                    _bTopic.clear();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

//_dialogSwtich

  Future<Null> _dialogSwtich(BuildContext context) {
    _sName.clear();
    _sTopic.clear();
    _sPublishOn.clear();
    _sPublishOff.clear();
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Swtich'),
        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 8),
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _sName,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _sTopic,
                  decoration: InputDecoration(
                    labelText: "Topic",
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _sPublishOn,
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                TextFormField(
                  controller: _sPublishOff,
                  decoration: InputDecoration(
                    labelText: "Text",
                    hintText: "e.g.On,Off",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    // prefixIcon: const Icon(
                    //   Icons.create,
                    //   color: Colors.black,
                    // ),
                  ),
                ),
                new Padding(padding: EdgeInsets.only(top: 8.0)),
                RaisedButton(
                  child: Text('OK'),
                  onPressed: _onSwitchSave
                  // () {
                  //   _bodySwitch();
                  //   _sName.clear();
                  //   _sTopic.clear();
                  //   _sTextOn.clear();
                  //   _sTextOff.clear();
                  //   Navigator.pop(context);
                  //   Navigator.pop(context);
                  // }
                  ,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //dialogTimepicker

  // Future<Null> _dialogTimepicker(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: Text('Swtich'),
  //       content: SingleChildScrollView(
  //         child: Container(
  //           child: Column(
  //             children: <Widget>[
  //               TextField(
  //                 controller: _sName,
  //                 decoration: InputDecoration(
  //                   hintText: "Name",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               TextField(
  //                 controller: _sTopic,
  //                 decoration: InputDecoration(
  //                   hintText: "Topic",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               TextField(
  //                 decoration: InputDecoration(
  //                   hintText: "test",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               TextField(
  //                 decoration: InputDecoration(
  //                   hintText: "test",
  //                   prefixIcon: const Icon(
  //                     Icons.create,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //               new Padding(padding: EdgeInsets.only(top: 5.0)),
  //               RaisedButton(
  //                 child: Text('ok'),
  //                 onPressed: () {
  //                   // _bodySwitch();
  //                   // _sname.clear();
  //                   // _stopic.clear();
  //                   Navigator.pop(context);
  //                   Navigator.pop(context);
  //                 },
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget bodyBuild(BuildContext contex, int index) {
    return lst[index];
  }

//ส่วนข้อมูลผู้ใช้งาน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.grey[300]),
          title: Text('Dashboard', style: TextStyle(color: Colors.grey[300])),
          backgroundColor: Colors.black,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _asyncSimpleDialog(context);
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(3),
          itemBuilder: bodyBuild,
          itemCount: lst.length,
        ),
        drawer: new Container(
          constraints: new BoxConstraints.expand(
            width: MediaQuery.of(context).size.width - 90,
          ),
          color: Colors.white,
          alignment: Alignment.center,
          child: new ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              new DrawerHeader(
                  padding: const EdgeInsets.all(16.0),
                  child: new UserAccountsDrawerHeader(
                    accountName: new Text(
                      'Someusername',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    accountEmail: new Text(
                      'Someemail@flutter.com',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    currentAccountPicture: FlutterLogo(),
                    decoration: new BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                  decoration: new BoxDecoration(color: Colors.black)),
              new ListTile(
                  leading: new Icon(Icons.link),
                  title: new Text("Connection"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            connectionPage(_userId, _client)));
                  }),
              new ListTile(
                  leading: new Icon(Icons.person),
                  title: new Text("Account Settings"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => accountSettings()));
                  }),
              new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text("Close"),
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ));
  }
}
