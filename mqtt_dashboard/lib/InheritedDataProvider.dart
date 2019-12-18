import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

class InheritedDataProvider extends InheritedWidget {
  mqtt.MqttClient client;

  InheritedDataProvider({
    Widget child,
    this.client,
  }) : super(child: child);
  @override
  bool updateShouldNotify(InheritedDataProvider oldWidget) =>
      client != oldWidget.client;
  static InheritedDataProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(InheritedDataProvider);
}
