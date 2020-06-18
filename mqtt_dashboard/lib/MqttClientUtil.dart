import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

class MqttClientUtil {
  MqttClientUtil._privateConstructor();

  static final MqttClientUtil _instance = MqttClientUtil._privateConstructor();

  static MqttClientUtil get instance => _instance;

  mqtt.MqttClient client;
  StreamSubscription subscription;
  mqtt.MqttConnectionState connectionState;
  String clientIdentifier = 'android';

  Future<bool> connect(
      String server, String port, String user, String pass) async {
    // if (_formKey.currentState.validate()) {}
    client = mqtt.MqttClient(server, '');
    client.port = int.parse(port);

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
      await client.connect(user, pass);
    } catch (e) {
      print(e);
      disconnect();
    }

    /// Check if we are connected
    if (client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
      // print(
      //     "###########################################################################");
      // print(mqtt.MqttConnectionState.connected);
      // print(
      //     "###########################################################################");
      connectionState = mqtt.MqttConnectionState.connected;
      return true;
      // showToast("Connected", duration: Toast.LENGTH_LONG, gravity: 0);

      // setState(() {
      //   _checkConnect = true;
      // });

      // subscription = client.updates.listen(_onMessage);

    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus}');
      disconnect();
      return false;
    }
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    //topics.clear();
    connectionState = mqtt.MqttConnectionState.disconnected;
    client = null;
    subscription = null;
    // showToast("Disconnected", duration: Toast.LENGTH_LONG, gravity: 0);
    print('[MQTT client] MQTT client disconnected');
  }

  void disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    // subscription.cancel();
    // setState(() {
    //   _checkConnect = false;
    // });
    _onDisconnected();
  }

  bool checkStatus() {
    if (client != null &&
        client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
      return true;
    } else {
      return false;
    }
  }

  void setOnMessage(Function(List<mqtt.MqttReceivedMessage>) method) {
    subscription = client.updates.listen(method);
  }
}
