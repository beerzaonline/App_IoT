import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_dashboard/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

TextEditingController _server = TextEditingController();
TextEditingController _port = TextEditingController();
TextEditingController _user = TextEditingController();
TextEditingController _pass = TextEditingController();

String clientIdentifier = 'android';

mqtt.MqttConnectionState connectionState;

StreamSubscription subscription;

List<String> _dataConnect = List<String>();

GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class DialogConnection extends StatefulWidget {
  int _userId;
  DialogConnection(this._userId);

  @override
  _DialogConnectionState createState() => _DialogConnectionState(_userId);
}

class _DialogConnectionState extends State<DialogConnection> {
  int _userId;
  _DialogConnectionState(this._userId);

  mqtt.MqttClient _client;

  bool _checkConnect = false;

  @override
  void initState() {
    if (_client != null) {
      if (_client.connectionStatus.state ==
          mqtt.MqttConnectionState.connected) {
        _checkConnect = true;
        // subscription = _client.updates.listen(_onMessage);
        // _subscribeToTopic("/ESP/LED1");
        // _subscribeToTopic("/ESP/SEND1");
      } else {
        _checkConnect = false;
      }
    } else {
      _checkConnect = false;
    }

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
    super.initState();
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

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void _subscribeToTopic(String topic) {
    if (_checkConnect) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      _client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
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
      _checkConnect = true;
      setState(() {});
      _dataConnect.add(_server.text);
      _dataConnect.add(_port.text);
      _dataConnect.add(_user.text);
      _dataConnect.add(_pass.text);
      _saveDataConnect(_dataConnect);
      Navigator.pop(context,_userId);
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${_client.connectionStatus}');
      _checkConnect = false;
      _disconnect();
    }
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      connectionState = mqtt.MqttConnectionState.disconnected;
      _client = null;
      subscription = null;
      // _checkConnect = false;
      showToast("Disconnected", duration: Toast.LENGTH_LONG, gravity: 0);
    });
    print('[MQTT client] MQTT client disconnected');
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    _client.disconnect();
    // subscription.cancel();
    _onDisconnected();
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
