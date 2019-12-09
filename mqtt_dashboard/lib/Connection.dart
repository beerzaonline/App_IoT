import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

void main() => runApp(new connectionPage());

class connectionPage extends StatefulWidget {
  @override
  _connectionPageState createState() => _connectionPageState();
}

class _connectionPageState extends State<connectionPage> {
  TextEditingController _server = TextEditingController();

  TextEditingController _port = TextEditingController();

  TextEditingController _user = TextEditingController();

  TextEditingController _pass = TextEditingController();

  String broker = 'postman.cloudmqtt.com';

  int port = 14893;

  String username = 'aaa';

  String passwd = 'aaa';

  String clientIdentifier = 'android';

  mqtt.MqttClient client;

  mqtt.MqttConnectionState connectionState;

  double _temp = 20;

  String _tempMassage;

  StreamSubscription subscription;

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
              title:
                  Text('Connection', style: TextStyle(color: Colors.grey[300])),
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
                          new TextField(
                            controller: _server,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Server',
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
                          //  new Padding(padding: EdgeInsets.only(top: 3.0)),
                          new TextField(
                            controller: _port,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Port',
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
                          // new Padding(padding: EdgeInsets.only(top: 5.0)),
                          new TextField(
                            controller: _user,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Username',
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              prefixIcon: const Icon(
                                Icons.account_box,
                                color: Colors.white,
                              ),
                              prefixText: ' ',
                              errorText: null,
                              errorStyle: null,
                            ),
                          ),
                          // new Padding(padding: EdgeInsets.only(top: 5.0)),
                          new TextField(
                            obscureText: true,
                            controller: _pass,
                            style: TextStyle(color: Colors.grey),
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Password',
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
                          new Padding(padding: EdgeInsets.only(top: 20.0)),
                          ButtonTheme(
                            minWidth: 150.0,
                            height: 50.0,
                            child: RaisedButton(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                              ),
                              onPressed: _connect,
                              child: Text("Connecting"),
                              color: Colors.grey[300],
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
                              onPressed: _disconnect,
                              child: Text("Disconnect"),
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            ])));
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  void _connect() async {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    client = mqtt.MqttClient(broker, '');
    client.port = port;

    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.

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
      await client.connect(username, passwd);
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
      // Fluttertoast.showToast(
      //     msg: "Connected",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIos: 1,
      //     backgroundColor: Colors.white,
      //     textColor: Colors.black,
      //     fontSize: 16.0);
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);

    _subscribeToTopic("/ESP/LED1");
    _subscribeToTopic("/ESP/LED2");
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    // subscription.cancel();
    _onDisconnected();
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      connectionState = mqtt.MqttConnectionState.disconnected;
      client = null;
      subscription = null;
    });
    print('[MQTT client] MQTT client disconnected');
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
    print(client.connectionStatus);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    // _temp = double.parse(message);
    setState(() {
      _tempMassage = message;
    });
  }

  void _onPublish() {
    const String pubTopic = '/ESP/LED1';
    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();
    builder.addString('${_tempMassage == "led1on" ? "led1off" : "led1on"}');
    client.publishMessage(pubTopic, mqtt.MqttQos.exactlyOnce, builder.payload);
  }
}
