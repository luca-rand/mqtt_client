/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/06/2017
 * Copyright :  S.Hamblett
 */

import '../mqtt_client_mqtt_header.dart';
import '../mqtt_client_mqtt_message.dart';
import '../mqtt_client_mqtt_message_type.dart';

/// Implementation of an MQTT ping Request Message.
class MqttPingRequestMessage extends MqttMessage {
  /// Initializes a new instance of the MqttPingRequestMessage class.
  MqttPingRequestMessage() {
    header = MqttHeader().asType(MqttMessageType.pingRequest);
  }

  /// Initializes a new instance of the MqttPingRequestMessage class.
  MqttPingRequestMessage.fromHeader(MqttHeader header) {
    this.header = header;
  }

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    sb.write(super.toString());
    return sb.toString();
  }
}
