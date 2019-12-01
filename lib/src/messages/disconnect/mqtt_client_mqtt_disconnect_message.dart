/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/06/2017
 * Copyright :  S.Hamblett
 */

import '../mqtt_client_mqtt_header.dart';
import '../mqtt_client_mqtt_message.dart';
import '../mqtt_client_mqtt_message_type.dart';

/// Implementation of an MQTT Disconnect Message.
class MqttDisconnectMessage extends MqttMessage {
  /// Initializes a new instance of the MqttDisconnectMessage class.
  MqttDisconnectMessage() {
    header = MqttHeader().asType(MqttMessageType.disconnect);
  }

  /// Initializes a new instance of the MqttDisconnectMessage class.
  MqttDisconnectMessage.fromHeader(MqttHeader header) {
    this.header = header;
  }

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    sb.write(super.toString());
    return sb.toString();
  }
}
