/*
 * Package : mqtt_client
 * Author : L. Casonato <hello@lcas.dev>
 * Date   : 01/12/2019
 * Copyright :  L. Casonato
 */

import 'package:event_bus/event_bus.dart' as events;
export './mqtt_client_mqtt_normal_connection.dart';
export './mqtt_client_mqtt_secure_connection.dart';
export './mqtt_client_mqtt_ws2_connection.dart';
export './mqtt_client_mqtt_ws_connection.dart';

class MqttWebWsConnection {
  /// Default constructor
  MqttWebWsConnection(events.EventBus eventBus);

  /// Initializes a new instance of the MqttConnection class.
  MqttWebWsConnection.fromConnect(
      String server, int port, events.EventBus eventBus);
}

/// If the library is being used on the web or not
const bool isWeb = false;
