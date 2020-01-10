import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'Dashboard.dart';

// void main() => runApp(new connectionPage());

class connectionPage extends StatefulWidget {
  int _userId;
  mqtt.MqttClient _client;
  connectionPage(this._userId, this._client);
  @override
  _connectionPageState createState() => _connectionPageState(_userId, _client);
}

class _connectionPageState extends State<connectionPage> {
  int _userId;
  mqtt.MqttClient client;
  _connectionPageState(this._userId, this.client);

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _server = TextEditingController();
  TextEditingController _port = TextEditingController();
  TextEditingController _user = TextEditingController();
  TextEditingController _pass = TextEditingController();

  String clientIdentifier = 'android';

  mqtt.MqttConnectionState connectionState;

  double _temp = 20;

  String _tempMassage;

  StreamSubscription subscription;
  List<String> _dataConnect = List<String>();

  @override
  void initState() {
    
    if (client != null) {
      // print(client.connectionStatus.state);
      // print(mqtt.MqttConnectionState.connected);

      if (client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
        connectionState = mqtt.MqttConnectionState.connected;
      } else {
        connectionState = mqtt.MqttConnectionState.disconnected;
      }
    } else {
      connectionState = mqtt.MqttConnectionState.disconnected;
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

  @override
  Widget build(BuildContext context) {
    // var aaa = InheritedDataProvider.of(context).client;
    // print(client);

    // void _subscribeToTopic(String topic) {
    //   if (connectionState == mqtt.MqttConnectionState.connected) {
    //     print('[MQTT client] Subscribing to ${topic.trim()}');
    //     client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    //   }
    // }

    void showToast(String msg, {int duration, int gravity}) {
      Toast.show(msg, context, duration: duration, gravity: gravity);
    }

    // void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    //   print(event.length);
    //   final mqtt.MqttPublishMessage recMess =
    //       event[0].payload as mqtt.MqttPublishMessage;
    //   final String message = mqtt.MqttPublishPayload.bytesToStringAsString(
    //       recMess.payload.message);
    
    //   print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
    //       'payload is <-- ${message} -->');
    //   print("[MQTT client] message with topic: ${event[0].topic}");
    //   print("[MQTT client] message with message: ${message}");
    //   // _temp = double.parse(message);
    //   print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx");
    //   // setState(() {
    //   //   _tempMassage = message;
    //   // });
    // }

    void _onDisconnected() {
      print('[MQTT client] _onDisconnected');
      setState(() {
        //topics.clear();
        connectionState = mqtt.MqttConnectionState.disconnected;
        client = null;
        subscription = null;
        showToast("Disconnected", duration: Toast.LENGTH_LONG, gravity: 0);
      });
      print('[MQTT client] MQTT client disconnected');
    }

    void _disconnect() {
      print('[MQTT client] _disconnect()');
      client.disconnect();
      // subscription.cancel();
      _onDisconnected();
    }

    void _connect() async {
      if (_formKey.currentState.validate()) {}
      client = mqtt.MqttClient(_server.text, '');
      client.port = int.parse(_port.text);

      /// Set logging on if needed, defaults to off
      client.logging(on: true);

      /// If you intend to use a keep alive value in your connect message that is not the default(60s)
      /// you must set it here
      client.keepAlivePeriod = 30;

      /// Add the unsolicited disconnection callback
      client.onDisconnected = _onDisconnected;

      /// Create a connection message to use or use the default one. The default one sets the
      /// client identifier, any supplied username/password, the default keepalive interval(60s)
      /// and clean session, an example of a specific one below.
      final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
          .withClientIdentifier(clientIdentifier)
          .startClean() // Non persistent session for testing
          .keepAliveFor(30)
          .withWillQos(mqtt.MqttQos.atMostOnce);
      print('[MQTT client] MQTT client connecting....');
      client.connectionMessage = connMess;

      /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
      /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
      /// never send malformed messages.

      try {
        await client.connect(_user.text, _pass.text);
      } catch (e) {
        print(e);
        _disconnect();
      }

      /// Check if we are connected
      if (client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
        // print(
        //     "###########################################################################");
        // print(mqtt.MqttConnectionState.connected);
        // print(
        //     "###########################################################################");
        connectionState = mqtt.MqttConnectionState.connected;
        showToast("Connected", duration: Toast.LENGTH_LONG, gravity: 0);
        setState(() {});
        _dataConnect.add(_server.text);
        _dataConnect.add(_port.text);
        _dataConnect.add(_user.text);
        _dataConnect.add(_pass.text);
        _saveDataConnect(_dataConnect);
      } else {
        print('[MQTT client] ERROR: MQTT client connection failed - '
            'disconnecting, state is ${client.connectionStatus}');
        _disconnect();
      }

      /// The client has a change notifier object(see the Observable class) which we then listen to to get
      /// notifications of published updates to each subscribed topic.
      // subscription = client.updates.listen(_onMessage);

      // _subscribeToTopic("/esp");
      // _subscribeToTopic("/ESP/LED1");
      // _subscribeToTopic("/ESP/SEND1");
      // _subscribeToTopic("/ESP/LED3");
      // _subscribeToTopic("/ESP/LED4");
    }

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Connection', style: TextStyle(color: Colors.grey[300])),
          backgroundColor: Colors.black,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              dashboard(_userId, client)));
                },
              );
            },
          ),
        ),
        body: ListView(children: <Widget>[
          new Container(
              padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 20.0),
              child: new Container(
                child: new Center(
                  child: new Column(
                    children: [
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
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
                          onPressed:
                              // () {
                              // if (_formKey.currentState.validate()) {}
                              connectionState ==
                                      mqtt.MqttConnectionState.connected
                                  ? _disconnect
                                  : _connect,
                          child: connectionState ==
                                  mqtt.MqttConnectionState.connected
                              ? Text("Disconnect")
                              : Text("Connect"),
                          color: Colors.grey[300],
                          // }
                        ),
                      ),
                      // new Padding(padding: EdgeInsets.only(top: 20.0)),
                      // ButtonTheme(
                      //   minWidth: 150.0,
                      //   height: 50.0,
                      //   child: RaisedButton(
                      //     shape: new RoundedRectangleBorder(
                      //       borderRadius: new BorderRadius.circular(15.0),
                      //     ),
                      //     onPressed: () => Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (BuildContext context) =>
                      //                 testPage(client))),
                      //     child: Text("go to test page"),
                      //     color: Colors.grey[300],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ))
        ]));
  }
}
