import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mqtt_dashboard/GetResponses.dart';
import 'package:mqtt_dashboard/Model/SaveCardModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:http/http.dart' as http;
import 'Model/ListCardModel.dart';
import 'MqttClientUtil.dart';
import 'config.dart';
import 'main.dart';

//List _temp = List();
TextEditingController _sName = TextEditingController();
TextEditingController _sTopic = TextEditingController();
//TextEditingController _sTextOn = TextEditingController();
//TextEditingController _sTextOff = TextEditingController();
TextEditingController _sPublishOn = TextEditingController();
TextEditingController _sPublishOff = TextEditingController();
// TextEditingController _sReciveOn = TextEditingController();
// TextEditingController _sReciveOff = TextEditingController();

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

//List<String> _dataSwitch = List<String>();

GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class dashboard extends StatefulWidget {
  int _userId;

  dashboard(this._userId);

  @override
  State<StatefulWidget> createState() {
    return _dashboard(_userId);
  }
}

class _dashboard extends State {
  int _userId;

  _dashboard(this._userId);

  List lst = List();
  // List listCard = List();
  List<ListCard> listCard = List<ListCard>();
  bool toggleStatus = false;
  String _tempMassage;

  String offValue;
  String onValue;

  @override
  void initState() {
//     _getDataRecive("on").then((value) => onValue = value);
//     _getDataRecive("off").then((value) => offValue = value);

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

  _saveDataSwitch(List<String> values) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userId.toString(), values);
  }

  Future _getDataSwitch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> temp = await prefs.getStringList(_userId.toString());
    return temp;
  }

  void _onPublish(String pubTopic, String msg) {
    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();
    builder.addString('$msg');
    MqttClientUtil.instance.client
        .publishMessage(pubTopic, mqtt.MqttQos.exactlyOnce, builder.payload);
  }

  // void checkData() async {
  //   GetResponses obj = GetResponses();
  //   Map response = await obj.Get(
  //       url: "/api/card/updateData",
  //       body: {"userId": _userId.toString(), "topic": "/ESP/LED1"});
  //   print(response['status']);
  // }

  void _subscribeToTopic(String topic) {
    if (MqttClientUtil.instance.checkStatus()) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      MqttClientUtil.instance.client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
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
    if (message == "on" || message == "off") {
      listCard.asMap().forEach((index, element) { 
        ListCard _card = element;
        // String dataValue;
        if (_card.topic == "${event[0].topic}") {
          if (message != null) {
            if (message == "on") {
              toggleStatus = true;
              // dataValue = data['onValue'];
            } else if (message == "off") {
              toggleStatus = false;
              // dataValue = data['offValue'];
            }
//            print("OLD ${_tempUI[i]}");
            _card.dataNow = toggleStatus ? "on" : "off";
            listCard.removeAt(index);
            listCard.insert(index, _card);
//            print("NOW ${_tempUI[i]}");
            updata(_card, message.toString());
          }
          setState(() {
            lst.removeAt(index);
            lst.insert(index, _bodyCard(_card, index, toggleStatus));
          });
        }
      });
    }
    // });
  }

  void _onSwitchSave() async {
    var uri = Uri.http(config.API_Url, APIPath.api_save_card, {
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
    SaveCardModel _listCard = SaveCardModel.fromMap(jsonDecode(response.body) as Map);

    if (_listCard.status == 0) {
      ListCard _card = _listCard.data;
      if (MqttClientUtil.instance.checkStatus()) {
        _subscribeToTopic("${_card.topic}");
      }
//       _saveDataRecive("on", _sReciveOn.text);
//       _saveDataRecive("off", _sReciveOff.text);
      Navigator.pop(context);
      setState(() {
        // lst.clear();
        listCard.add(_card);
        _createSwitch(_card);
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

  void _onSwitchEdit(int id, String dataNow) async {
    var uri = Uri.http(config.API_Url, APIPath.api_edit_card, {
      "id": id.toString(),
      "userId": _userId.toString(),
      "title": _sName.text,
      "topic": _sTopic.text,
      "onValue": _sPublishOn.text,
      "offValue": _sPublishOff.text,
      "dataNow": dataNow
    });

    var response = await http.get(uri, headers: {
      // HttpHeaders.authorizationHeader: 'Token $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    print(response.body);
    Map jsonData = jsonDecode(response.body) as Map;

    if (jsonData['status'] == 0) {
      Iterable search =
          listCard.where((a) => a.id.toString().contains(id.toString()));
      ListCard _card = search.toList()[0];

      if (_card.topic != _sTopic.text) {
        if (MqttClientUtil.instance.checkStatus()) {
          _subscribeToTopic("${_sTopic.text}");
        }
      }

      ListCard _newCard = ListCard();
      _newCard.id = id;
      _newCard.userId = _userId;
      _newCard.title = _sName.text;
      _newCard.topic = _sTopic.text;
      _newCard.onValue = _sPublishOn.text;
      _newCard.offValue = _sPublishOff.text;
      _newCard.dataNow = dataNow;

      // var dataString = {
      //   "id": id,
      //   "userId": _userId,
      //   "title": _sName.text,
      //   "topic": _sTopic.text,
      //   "onValue": _sPublishOn.text,
      //   "offValue": _sPublishOff.text,
      //   "dataNow": dataNow
      // };

      print("DATASTRING ${_newCard}");
      int index = listCard.indexOf(_card);
      listCard.removeAt(index);
      listCard.insert(index, _newCard);

      setState(() {
        lst.removeAt(index);
        lst.insert(
            index, _bodyCard(_newCard, index, dataNow == "on" ? true : false));
      });

      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      // showToast("Username Or Password Error",
      //     duration: Toast.LENGTH_LONG,
      //     gravity: 0,
      //     backgroundColor: Colors.white54);
    }
  }

  void updata(ListCard _listCard, String massage) async {
    var uri = Uri.http('${config.API_Url}', '/api/card/updateData', {
      "idCard": _listCard.id.toString(),
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
          "==================================UPDATE DATA==================================");
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
    ListCardModel cardModel =
        ListCardModel.fromMap(jsonDecode(response.body) as Map);

    if (cardModel.status == 0) {
      listCard.addAll(cardModel.data);
      listCard.sort((a, b) => a.id.toString().compareTo(b.id.toString()));

      listCard.forEach((element) {
        // _tempUI.add(element);
        _createSwitch(element);
      });
    } else {
      // showToast("Username Or Password Error",
      //     duration: Toast.LENGTH_LONG,
      //     gravity: 0,
      //     backgroundColor: Colors.white54);
    }
  }

//card Switch

  void _createSwitch(ListCard _listCard) {
    int _count;
    bool check;

    if (_listCard.dataNow == "on") {
      check = true;
    } else {
      check = false;
    }

    _count = lst.length;
    setState(() {
      lst.add(_bodyCard(_listCard, _count, check));
    });
  }

  Widget _bodyCard(ListCard _listCard, int _count, bool _check) {
    return Card(
      child: ListTile(
        onLongPress: () {
          _menu(context, _listCard.id);
        },
        title: Text(_listCard.title),
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
                onClick(_listCard, _count, _check);
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

  void onClick(ListCard _listCard, int _count, bool _check) {
    _check = !_check;
    print(_listCard);
    _onPublish("${_listCard.topic}",
        _check ? "${_listCard.onValue}" : "${_listCard.offValue}");
    setState(() {
      lst.removeAt(_count);
      lst.insert(_count, _bodyCard(_listCard, _count, _check));
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
                onPressed: () {
                  _dialogSwtich(context, idCard);
                },
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
                onPressed: () {
                  _dialogdelete(context, idCard);
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

  // dialogdelete

  Future<Null> _dialogdelete(BuildContext context, int idCard) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Delete", textAlign: TextAlign.center),
              content: Text("Are you sure you want to delete ? ",
                  textAlign: TextAlign.center),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancle"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Delete"),
                  onPressed: () async {
                    GetResponses obj = GetResponses();
                    Map res = await obj.Get(
                        url: "/api/card/delete",
                        body: {"idCard": idCard.toString()});
                    if (res['status'] == 0) {
                      if (listCard.isNotEmpty && listCard != null) {
                        listCard.asMap().forEach((index, element) {
                          ListCard _card = element;

                          if (_card.id == idCard) {
                            // listCard.removeAt(index);
                            setState(() {
                              lst.removeAt(index);
                              // lst.clear();
                              // this._listCard();
                            });
                          }
                        });
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {}
                  },
                )
              ],
            ));
  }

//_dialogSwtich

  Future<Null> _dialogSwtich(BuildContext context, int idCard) {
    String _dataNow;
    if (idCard == null) {
      _sName.clear();
      _sTopic.clear();
      _sPublishOn.clear();
      _sPublishOff.clear();
    } else {
      Iterable search =
          listCard.where((a) => a.id.toString().contains(idCard.toString()));
      Map<String, dynamic> dataMap = search.toList()[0];
      setState(() {
        _sName.text = dataMap['title'].toString();
        _sTopic.text = dataMap['topic'].toString();
        _sPublishOn.text = dataMap['onValue'].toString();
        _sPublishOff.text = dataMap['offValue'].toString();
      });
      _dataNow = dataMap['dataNow'];
    }
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
//                           Padding(
//                             padding: EdgeInsets.only(top: 20),
//                             child: Text('Recive Value'),
//                           ),
//                           // Divider(
//                           //   color: Colors.red,
//                           // ),
//                           TextFormField(
//                             controller: _sReciveOn,
//                             decoration: InputDecoration(
//                               labelText: 'onValueRecive',
//                               // prefixIcon: const Icon(
//                               //   Icons.create,
//                               //   color: Colors.black,
//                               // ),
//                             ),
//                             validator: (String value) {
//                               if (value.trim().isEmpty) {
//                                 return "Please Enter On Value";
//                               }
//                             },
//                           ),
//                           TextFormField(
//                             controller: _sReciveOff,
//                             decoration: InputDecoration(
//                               labelText: 'OffValueRecive',
//                               // prefixIcon: const Icon(
//                               //   Icons.create,
//                               //   color: Colors.black,
//                               // ),
//                             ),
//                             validator: (String value) {
//                               if (value.trim().isEmpty) {
//                                 return "Please Enter Off Value";
//                               }
//                             },
//                           ),
                          new Padding(padding: EdgeInsets.only(top: 8.0)),
                          RaisedButton(
                            child: Text('OK'),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                idCard == null
                                    ? _onSwitchSave()
                                    : _onSwitchEdit(idCard, _dataNow);
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
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
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
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  labelText: 'Server',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[300]),
                                  prefixIcon: const Icon(
                                    Icons.account_balance,
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
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
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  labelText: 'Port',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[300]),
                                  prefixIcon: const Icon(
                                    Icons.settings_input_component,
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
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
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  labelText: 'Username',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[300]),
                                  prefixIcon: const Icon(
                                    Icons.account_box,
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
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
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  labelText: 'Password',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[300]),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
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
                          onPressed: () {
                            if (!MqttClientUtil.instance.checkStatus()) {
                              MqttClientUtil.instance
                                  .connect(_server.text, _port.text, _user.text,
                                      _pass.text)
                                  .then((value) {
                                if (value &&
                                    MqttClientUtil.instance.checkStatus()) {
                                  MqttClientUtil.instance
                                      .setOnMessage(_onMessage);

                                  if (listCard.isNotEmpty) {
                                    listCard.forEach((element) {
                                      ListCard _card = element;
                                      _subscribeToTopic(_card.topic);
                                    });
                                  }

                                  setState(() {});
                                  this.setState(() {});
                                  this.showToast("Connected",
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                }
                              });
                            } else {
                              MqttClientUtil.instance.disconnect();
                              setState(() {});
                              this.setState(() {});
                              this.showToast("DisConnected",
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.BOTTOM);
                            }
                          },
                          child: MqttClientUtil.instance.checkStatus()
                              ? Text("Disconnect")
                              : Text("Connect"),
                          color: Colors.grey[300],
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            }));
  }

  // dialoglogout

  Future<Null> _dialoglogout(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Logout", textAlign: TextAlign.center),
              content: Text("Are you sure you want to logout ? ",
                  textAlign: TextAlign.center),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancle"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Logout"),
                  onPressed: () {
                    _logout();
                    MqttClientUtil.instance.checkStatus()
                        ? MqttClientUtil.instance.disconnect()
                        : null;
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => MyApp()));
                  },
                )
              ],
            ));
  }

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
            Text(
                MqttClientUtil.instance.checkStatus()
                    ? 'Connected'
                    : 'Disconnected',
                style: TextStyle(color: Colors.grey[300], fontSize: 12))
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(MdiIcons.linkVariant),
              tooltip: 'Connection',
              onPressed: () {
                _dialogConnect(context).then((value) {
                  setState(() {});
                });
                // return showDialog(
                //     context: context,
                //     builder: (_) => DialogConnection(_userId));
              }),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () {
              _dialoglogout(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _dialogSwtich(context, null);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(3),
        itemBuilder: bodyBuild,
        itemCount: lst.length,
      ),
    );
  }
}
