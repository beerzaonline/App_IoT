import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_dashboard/Connection.dart';

class testPage extends StatefulWidget {
  mqtt.MqttClient _client;
  testPage(mqtt.MqttClient client) {
    this._client = client;
  }
  @override
  _testPageState createState() => _testPageState(_client);
}

class _testPageState extends State<testPage> {
  mqtt.MqttClient _client;
  _testPageState(mqtt.MqttClient client) {
    this._client = client;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send'),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: RaisedButton(
            child: Text('OK'),
            onPressed: () => _onPublish("led1on"),
          ),
        ),
      ),
    );
  }

  void _onPublish(String msg) {
    const String pubTopic = '/ESP/LED1';
    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();
    builder.addString('$msg');
    _client.publishMessage(pubTopic, mqtt.MqttQos.exactlyOnce, builder.payload);
  }
}
