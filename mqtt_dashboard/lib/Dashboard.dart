import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mqtt_dashboard/GetResponses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'Connection.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:http/http.dart' as http;
import 'config.dart';
import 'main.dart';

List _temp = List();
TextEditingController _sName = TextEditingController();
TextEditingController _sTopic = TextEditingController();
TextEditingController _sTextOn = TextEditingController();
TextEditingController _sTextOff = TextEditingController();
TextEditingController _sPublishOn = TextEditingController();
TextEditingController _sPublishOff = TextEditingController();
TextEditingController _sReciveOn = TextEditingController();
TextEditingController _sReciveOff = TextEditingController();

// TextEditingController _bName = TextEditingController();
// TextEditingController _bTopic = TextEditingController();
// TextEditingController _bTextOn = TextEditingController();
// TextEditingController _bTextOff = TextEditingController();
// TextEditingController _bPublishOn = TextEditingController();
// TextEditingController _bPublishOff = TextEditingController();

TextEditingController _server = TextEditingController();
TextEditingController _port = TextEditingController();
TextEditingController _user = TextEditingController();
TextEditingController _pass = TextEditingController();

String clientIdentifier = 'android';

mqtt.MqttConnectionState connectionState;

List<String> _dataConnect = List<String>();

GlobalKey<FormState> _formKey = GlobalKey<FormState>();

mqtt.MqttClient _client;

StreamSubscription subscription;

bool _checkConnect = false;

class dashboard extends StatefulWidget {
  int _userId;
  // mqtt.MqttClient _client;

  dashboard(this._userId);

  //print(_temp.length);

  @override
  State<StatefulWidget> createState() {
    return _dashboard(_userId);
  }
}

class _dashboard extends State {
  int _userId;
  // mqtt.MqttClient _client;

  _dashboard(this._userId);

  List lst = List();
  List _tempUI = List();
  bool toggleStatus = false;
  String _tempMassage;

  String offValue;
  String onValue;

  @override
  void initState() {
    if (_client != null) {
      if (_client.connectionStatus.state ==
          mqtt.MqttConnectionState.connected) {
        _checkConnect = true;
      } else {
        _checkConnect = false;
      }
    } else {
      _checkConnect = false;
    }

    _getDataRecive("on").then((value) => onValue = value);
    _getDataRecive("off").then((value) => offValue = value);

    _getDataConnect().then((data) {
      if (data.toString() != "[]") {
        setState(() {
          _server.text = data[0];
          _port.text = data[1];
          _user.text = data[2];
          _pass.text = data[3];
        });
      }
    });

    this._listCard();
    super.initState();
    // }
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("id", null);
  }

  _saveDataConnect(List<String> values) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userId.toString(), values);
  }

  Future _getDataConnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> temp = await prefs.getStringList(_userId.toString());
    return temp;
  }

  _saveDataRecive(String key, String values) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, values);
  }

  Future _getDataRecive(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String temp = await prefs.getString(key);
    return temp;
  }

  void _onPublish(String pubTopic, String msg) {
    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();
    builder.addString('$msg');
    _client.publishMessage(pubTopic, mqtt.MqttQos.exactlyOnce, builder.payload);
  }

  // void checkData() async {
  //   GetResponses obj = GetResponses();
  //   Map response = await obj.Get(
  //       url: "/api/card/updateData",
  //       body: {"userId": _userId.toString(), "topic": "/ESP/LED1"});
  //   print(response['status']);
  // }

  void _subscribeToTopic(String topic) {
    if (_checkConnect) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      _client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void _connect() async {
    if (_formKey.currentState.validate()) {}
    _client = mqtt.MqttClient(_server.text, '');
    _client.port = int.parse(_port.text);

    /// Set logging on if needed, defaults to off
    _client.logging(on: true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    _client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    _client.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    _client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.

    try {
      await _client.connect(_user.text, _pass.text);
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (_client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
      // print(
      //     "###########################################################################");
      // print(mqtt.MqttConnectionState.connected);
      // print(
      //     "###########################################################################");
      connectionState = mqtt.MqttConnectionState.connected;
      showToast("Connected", duration: Toast.LENGTH_LONG, gravity: 0);

      setState(() {
        _checkConnect = true;
      });

      _dataConnect.add(_server.text);
      _dataConnect.add(_port.text);
      _dataConnect.add(_user.text);
      _dataConnect.add(_pass.text);
      _saveDataConnect(_dataConnect);

      subscription = _client.updates.listen(_onMessage);
      for (Map<String, dynamic> data in _tempUI) {
        _subscribeToTopic("${data['topic']}");
      }
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${_client.connectionStatus}');
      _disconnect();
    }
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    //topics.clear();
    connectionState = mqtt.MqttConnectionState.disconnected;
    _client = null;
    subscription = null;
    showToast("Disconnected", duration: Toast.LENGTH_LONG, gravity: 0);
    print('[MQTT client] MQTT client disconnected');
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    _client.disconnect();
    // subscription.cancel();
    setState(() {
      _checkConnect = false;
    });
    _onDisconnected();
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
        event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    // _temp = double.parse(message);
    // setState(() {
    // _tempMassage = message;
    if (message == onValue || message == offValue) {
      for (var i = 0; i < _tempUI.length; i++) {
        Map<String, dynamic> data = _tempUI[i];

        // String dataValue;
        if (data['topic'] == "${event[0].topic}") {
          if (message != null) {
            if (message == onValue) {
              toggleStatus = true;
              // dataValue = data['onValue'];
            } else if (message == offValue) {
              toggleStatus = false;
              // dataValue = data['offValue'];
            }
            updata(data, message.toString());
          }
          setState(() {
            lst.removeAt(i);
            lst.insert(i, _bodyCard(data, i, toggleStatus));
          });
        }
      }
    }
    // });
  }

  void _onSwitchSave() async {
    var uri = Uri.http('${config.API_Url}', '/api/card/save', {
      "userId": _userId.toString(),
      "title": _sName.text,
      "topic": _sTopic.text,
      "onValue": _sPublishOn.text,
      "offValue": _sPublishOff.text
      // "dataNow": _sPublishOff.text
    });
    var response = await http.get(uri, headers: {
      // HttpHeaders.authorizationHeader: 'Token $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    Map jsonData = jsonDecode(response.body) as Map;

    if (jsonData['status'] == 0) {
      Map<String, dynamic> data = jsonData['data'];
      if (_checkConnect) {
        _subscribeToTopic("${data['topic']}");
      }
      _saveDataRecive("on", _sReciveOn.text);
      _saveDataRecive("off", _sReciveOff.text);
      Navigator.pop(context);
      setState(() {
        // lst.clear();
        _tempUI.add(data);
        _createSwitch(data);
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

  // void _onButtonSave() async {
  //   var uri = Uri.http('${config.API_Url}', '/api/card/save', {
  //     "userId": _userId.toString(),
  //     "title": _bName.text,
  //     "topic": _bTopic.text,
  //     "onValue": _bPublishOn.text,
  //     "offValue": _bPublishOff.text
  //   });
  //   var response = await http.get(uri, headers: {
  //     // HttpHeaders.authorizationHeader: 'Token $token',
  //     HttpHeaders.contentTypeHeader: 'application/json',
  //   });
  //   Map jsonData = jsonDecode(response.body) as Map;

  //   if (jsonData['status'] == 0) {
  //     // int userId = jsonData['data'];
  //     Navigator.pop(context);
  //     Navigator.pop(context);
  //     setState(() {
  //       lst.clear();
  //       this._listCard();
  //     });
  //     // Navigator.push(
  //     //     context,
  //     //     MaterialPageRoute(
  //     //         builder: (BuildContext context) => dashboard(userId, null)));
  //   } else {
  //     // showToast("Username Or Password Error",
  //     //     duration: Toast.LENGTH_LONG,
  //     //     gravity: 0,
  //     //     backgroundColor: Colors.white54);
  //   }
  // }

  void updata(Map<String, dynamic> data, String massage) async {
    var uri = Uri.http('${config.API_Url}', '/api/card/updateData', {
      "idCard": data['id'].toString(),
      "userId": _userId.toString(),
      "dataNow": massage
    });
    var response = await http.get(uri, headers: {
      // HttpHeaders.authorizationHeader: 'Token $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    print(response.body);
    Map jsonData = jsonDecode(response.body) as Map;

    if (jsonData['status'] == 0) {
      print(
          "====================================================================UPDATE DATA");
    } else {
      print("ERROR");
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
        _tempUI.add(data);
        // _bodyButton(data);
        _createSwitch(data);
      }

      // Card tempCard = Card();
      // ListTile tempTitle = ListTile();
      // Text tempTopic;
      // String str = "led1on";
      // for (var i = 0; i < lst.length; i++) {
      //   tempCard = lst[i];
      //   tempTitle = tempCard.child;
      //   tempTopic = tempTitle.trailing;
      //   // Map<String,dynamic> tempData = {"asss":};
      //   // print("topic = ${tempTopic.data.substring(8)}");
      //   // print(str.substring(3,4));
      //   if(tempTopic.data.substring(8) == str.substring(3,4)){
      //     if(str == "led1on"){

      //     }
      //   }
      // }
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

  void _createSwitch(Map<String, dynamic> data) {
    int _count;
    bool check = false;

    if (data['dataNow'] == onValue) {
      check = true;
    } else {
      check = false;
    }

    _count = lst.length;
    setState(() {
      lst.add(_bodyCard(data, _count, check));
    });
  }

  Widget _bodyCard(Map<String, dynamic> _data, int _count, bool _check) {
    return Card(
      child: ListTile(
        onLongPress: () {
          _menu(context, _data['id']);
        },
        title: Text(_data['title']),
        // leading: Text(''),
        subtitle: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text('ON'),
            Padding(
              padding: EdgeInsets.only(right: 10),
            ),
            IconButton(
              onPressed: () {
                onClick(_data, _count, _check);
              },
              icon: Icon(
                _check ? MdiIcons.toggleSwitchOff : MdiIcons.toggleSwitch,
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
      ),
    );
  }

  void onClick(Map<String, dynamic> _data, int _count, bool _check) {
    _check = !_check;
    print(_data);
    _onPublish("${_data['topic']}",
        _check ? "${_data['onValue']}" : "${_data['offValue']}");
    setState(() {
      lst.removeAt(_count);
      lst.insert(_count, _bodyCard(_data, _count, _check));
    });
  }

//card Button

  void _bodyButton(Map<String, dynamic> data) {
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
            RaisedButton(
              onPressed: () {},
            ),
            // Padding(
            //   padding: EdgeInsets.only(left: 10),
            // ),
            // new Text('OFF'),
            // Padding(
            //   padding: EdgeInsets.only(right: 10),
            // ),
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
                    if (_tempUI.isNotEmpty && _tempUI != null) {
                      for (var i = 0; i < _tempUI.length; i++) {
                        Map<String, dynamic> data = _tempUI[i];
                        if (data['id'] == idCard) {
                          _tempUI.removeAt(i);
                          setState(() {
                            lst.removeAt(i);
                            // lst.clear();
                            // this._listCard();
                          });
                        }
                      }
                    }
                    Navigator.pop(context);
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

  // Future _asyncSimpleDialog(BuildContext context) async {
  //   return await showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (BuildContext context) {
  //         return SimpleDialog(
  //           titlePadding: EdgeInsets.fromLTRB(15.0, 24.0, 24.0, 0.0),
  //           contentPadding: EdgeInsets.fromLTRB(0, 10.0, 12.0, 16.0),
  //           title: const Text('Select Component'),
  //           children: <Widget>[
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 _dialogButton(context);
  //                 _bName.clear();
  //                 _bTopic.clear();
  //                 // Navigator.of(context).push(MaterialPageRoute(
  //                 //     builder: (BuildContext context) => addButton()));
  //               },
  //               child: Row(
  //                 children: <Widget>[
  //                   Icon(Icons.touch_app),
  //                   Padding(
  //                     padding: EdgeInsets.only(right: 10),
  //                   ),
  //                   const Text('Button'),
  //                 ],
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 _dialogSwtich(context);

  //                 // _dialogTimepicker(context);
  //                 // _sName.clear();
  //                 // _sTopic.clear();

  //                 // Navigator.of(context).push(MaterialPageRoute(
  //                 //     builder: (BuildContext context) => addSwitch()));
  //               },
  //               child: Row(
  //                 children: <Widget>[
  //                   Icon(MdiIcons.toggleSwitch),
  //                   Padding(
  //                     padding: EdgeInsets.only(right: 10),
  //                   ),
  //                   const Text('Switch'),
  //                 ],
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 // Navigator.of(context).push(MaterialPageRoute(
  //                 //     builder: (BuildContext context) => addTimepicker()));
  //               },
  //               child: Row(
  //                 children: <Widget>[
  //                   Icon(Icons.av_timer),
  //                   Padding(
  //                     padding: EdgeInsets.only(right: 10),
  //                   ),
  //                   const Text('TimePicker'),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

//_dialogButton

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
                  children: [
                    new Form(
                      key: _formKey,
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
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                return "Please enter Name";
                              }
                            },
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
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                return "Please enter Topic";
                              }
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text('Send Value'),
                          ),
                          TextFormField(
                            controller: _sPublishOn,
                            decoration: InputDecoration(
                              labelText: "onValue",
                              hintText: "e.g.On,Off",
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              // prefixIcon: const Icon(
                              //   Icons.create,
                              //   color: Colors.black,
                              // ),
                            ),
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                return "Please enter onValue";
                              }
                            },
                          ),
                          TextFormField(
                            controller: _sPublishOff,
                            decoration: InputDecoration(
                              labelText: "offValue",
                              hintText: "e.g.On,Off",
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              // prefixIcon: const Icon(
                              //   Icons.create,
                              //   color: Colors.black,
                              // ),
                            ),
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                return "Please enter offValue";
                              }
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text('Recive Value'),
                          ),
                          // Divider(
                          //   color: Colors.red,
                          // ),
                          TextFormField(
                            controller: _sReciveOn,
                            decoration: InputDecoration(
                              labelText: 'onValueRecive',
                              // prefixIcon: const Icon(
                              //   Icons.create,
                              //   color: Colors.black,
                              // ),
                            ),
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                return "Please Enter On Value";
                              }
                            },
                          ),
                          TextFormField(
                            controller: _sReciveOff,
                            decoration: InputDecoration(
                              labelText: 'OffValueRecive',
                              // prefixIcon: const Icon(
                              //   Icons.create,
                              //   color: Colors.black,
                              // ),
                            ),
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                return "Please Enter Off Value";
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.only(top: 8.0)),
                          RaisedButton(
                            child: Text('OK'),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _onSwitchSave();
                              }
                            }
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
                  ],
                ),
              ),
            )));
  }

  Future<Null> _dialogConnect(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('CONNECTION'),
        content: SingleChildScrollView(
          child: Container(
            child: Column(children: [
              new Padding(padding: EdgeInsets.only(top: 5.0)),
              new Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    new TextFormField(
                      controller: _server,
                      style: TextStyle(color: Colors.grey),
                      decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                              borderRadius: BorderRadius.circular(5.0)),
                          labelText: 'Server',
                          labelStyle: TextStyle(color: Colors.grey[300]),
                          prefixIcon: const Icon(
                            Icons.account_balance,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (String value) {
                        if (value.trim().isEmpty) {
                          return "Please enter Server";
                        }
                      },
                    ),
                    new Padding(padding: EdgeInsets.only(top: 20.0)),
                    new TextFormField(
                      controller: _port,
                      style: TextStyle(color: Colors.grey),
                      decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                              borderRadius: BorderRadius.circular(5.0)),
                          labelText: 'Port',
                          labelStyle: TextStyle(color: Colors.grey[300]),
                          prefixIcon: const Icon(
                            Icons.settings_input_component,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (String value) {
                        if (value.trim().isEmpty) {
                          return "Please enter Port";
                        }
                      },
                    ),
                    new Padding(padding: EdgeInsets.only(top: 20.0)),
                    new TextFormField(
                      controller: _user,
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
                            Icons.account_box,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (String value) {
                        if (value.trim().isEmpty) {
                          return "Please enter Username";
                        }
                      },
                    ),
                    new Padding(padding: EdgeInsets.only(top: 20.0)),
                    new TextFormField(
                      obscureText: true,
                      controller: _pass,
                      style: TextStyle(color: Colors.grey),
                      decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                              borderRadius: BorderRadius.circular(5.0)),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[300]),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (String value) {
                        if (value.trim().isEmpty) {
                          return "Please enter Password";
                        }
                      },
                    ),
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.only(top: 30.0)),
              ButtonTheme(
                minWidth: 150.0,
                height: 50.0,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                  ),
                  onPressed: _checkConnect ? _disconnect : _connect,
                  child: _checkConnect ? Text("Disconnect") : Text("Connect"),
                  color: Colors.grey[300],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // dialogTimepicker

  // Future<Null> _dialogTimepicker(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: Text('Swtich'),
  //       content: SingleChildScrollView(
  //         child: Container(
  //           child: Column(
  //             children: [
  //               new Form(
  //                   key: _formKey,
  //                   child: Column(children: <Widget>[
  //                     TextFormField(
  //                       controller: _sName,
  //                       decoration: InputDecoration(
  //                         hintText: "Name",
  //                         prefixIcon: const Icon(
  //                           Icons.create,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                     new Padding(padding: EdgeInsets.only(top: 5.0)),
  //                     TextFormField(
  //                       controller: _sTopic,
  //                       decoration: InputDecoration(
  //                         hintText: "Topic",
  //                         prefixIcon: const Icon(
  //                           Icons.create,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                     new Padding(padding: EdgeInsets.only(top: 5.0)),
  //                     TextFormField(
  //                       decoration: InputDecoration(
  //                         hintText: "test",
  //                         prefixIcon: const Icon(
  //                           Icons.create,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                     new Padding(padding: EdgeInsets.only(top: 5.0)),
  //                     TextFormField(
  //                       decoration: InputDecoration(
  //                         hintText: "test",
  //                         prefixIcon: const Icon(
  //                           Icons.create,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                     new Padding(padding: EdgeInsets.only(top: 5.0)),
  //                     RaisedButton(
  //                       child: Text('ok'),
  //                       onPressed: () {
  //                         // _bodySwitch();
  //                         // _sname.clear();
  //                         // _stopic.clear();
  //                         Navigator.pop(context);
  //                         Navigator.pop(context);
  //                       },
  //                     )
  //                   ]))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: new IconThemeData(color: Colors.grey[300]),
        title: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Dashboard', style: TextStyle(color: Colors.grey[300])),
            Text(_checkConnect ? 'Connected' : 'Disconnected',
                style: TextStyle(color: Colors.grey[300], fontSize: 12))
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(MdiIcons.linkVariant),
              tooltip: 'Connection',
              onPressed: () {
                _dialogConnect(context);
                // return showDialog(
                //     context: context,
                //     builder: (_) => DialogConnection(_userId));
              }),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () {
              _logout();
              _checkConnect ? _client.disconnect() : null;
              _client = null;
              subscription = null;
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => MyApp()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _dialogSwtich(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(3),
        itemBuilder: bodyBuild,
        itemCount: lst.length,
      ),

//ส่วนข้อมูลผู้ใช้งาน
      // drawer: new Container(
      //   constraints: new BoxConstraints.expand(
      //     width: MediaQuery.of(context).size.width - 130,
      //   ),
      //   color: Colors.white,
      //   alignment: Alignment.center,
      //   child: new ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       new DrawerHeader(
      //       padding: const EdgeInsets.all(0.0),
      //       child: new UserAccountsDrawerHeader(
      //       accountName: new Text(
      //         'Someusername',
      //         style: TextStyle(color: Colors.grey[300]),
      //       ),
      //       accountEmail: new Text(
      //         'Someemail@flutter.com',
      //         style: TextStyle(color: Colors.grey[300]),
      //       ),
      //       currentAccountPicture: FlutterLogo(),
      //         decoration: new BoxDecoration(
      //           color: Colors.white,
      //         ),
      //       ),
      //       decoration: new BoxDecoration(color: Colors.white)
      //       ),
      //       new ListTile(
      //           leading: new Icon(Icons.link),
      //           title: new Text("Connection"),
      //           onTap: () {
      //             Navigator.of(context).push(MaterialPageRoute(
      //                 builder: (BuildContext context) =>
      //                     connectionPage(_userId, _client)));
      //           }),
      //       new ListTile(
      //           leading: new Icon(Icons.exit_to_app),
      //           title: new Text("Logout"),
      //           onTap: () {
      //             _logout();
      //             Navigator.pop(context);
      //             Navigator.pushReplacement(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (BuildContext context) => MyApp()));
      //           }),
      //       new ListTile(
      //           leading: new Icon(Icons.close),
      //           title: new Text("Close"),
      //           onTap: () {
      //             Navigator.pop(context);
      //           }),
      //     ],
      //   ),
      // )
    );
  }
}
