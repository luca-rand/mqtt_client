/*
 * Package : mqtt_client
 * Author : L. Casonato <hello@lcas.dev>
 * Date   : 01/12/2019
 * Copyright :  L. Casonato
 */

import 'package:event_bus/event_bus.dart' as events;
export './mqtt_client_mqtt_web_ws_connection.dart';

class MqttNormalConnection {
  /// Default constructor
  MqttNormalConnection(events.EventBus eventBus);

  /// Initializes a new instance of the MqttConnection class.
  MqttNormalConnection.fromConnect(
      String server, int port, events.EventBus eventBus);
}

class MqttSecureConnection {
  /// Default constructor
  MqttSecureConnection(events.EventBus eventBus);

  /// Initializes a new instance of the MqttConnection class.
  MqttSecureConnection.fromConnect(
      String server, int port, events.EventBus eventBus);
}

class MqttWsConnection {
  /// Default constructor
  MqttWsConnection(events.EventBus eventBus);

  /// Initializes a new instance of the MqttConnection class.
  MqttWsConnection.fromConnect(
      String server, int port, events.EventBus eventBus);
}

class MqttWs2Connection {
  /// Default constructor
  MqttWs2Connection(events.EventBus eventBus);

  /// Initializes a new instance of the MqttConnection class.
  MqttWs2Connection.fromConnect(
      String server, int port, events.EventBus eventBus);
}

/// If the library is being used on the web or not
const bool isWeb = true;
