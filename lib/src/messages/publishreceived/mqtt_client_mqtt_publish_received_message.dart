/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/06/2017
 * Copyright :  S.Hamblett
 */

import '../../utility/mqtt_client_byte_buffer.dart';
import '../mqtt_client_mqtt_header.dart';
import '../mqtt_client_mqtt_message.dart';
import '../mqtt_client_mqtt_message_type.dart';
import './mqtt_client_mqtt_publish_received_variable_header.dart';

/// Implementation of an MQTT Publish Received Message.
class MqttPublishReceivedMessage extends MqttMessage {
  /// Initializes a new instance of the MqttPublishReceivedMessage class.
  MqttPublishReceivedMessage() {
    header = MqttHeader().asType(MqttMessageType.publishReceived);
    variableHeader = MqttPublishReceivedVariableHeader();
  }

  /// Initializes a new instance of the MqttPublishReceivedMessage class.
  MqttPublishReceivedMessage.fromByteBuffer(
      MqttHeader header, MqttByteBuffer messageStream) {
    this.header = header;
    variableHeader =
        MqttPublishReceivedVariableHeader.fromByteBuffer(messageStream);
  }

  /// Gets or sets the variable header contents. Contains extended metadata about the message
  MqttPublishReceivedVariableHeader variableHeader;

  /// Writes the message to the supplied stream.
  @override
  void writeTo(MqttByteBuffer messageStream) {
    header.writeTo(variableHeader.getWriteLength(), messageStream);
    variableHeader.writeTo(messageStream);
  }

  /// Sets the message identifier of the MqttMessage.
  MqttPublishReceivedMessage withMessageIdentifier(int messageIdentifier) {
    variableHeader.messageIdentifier = messageIdentifier;
    return this;
  }

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    sb.write(super.toString());
    sb.writeln(variableHeader.toString());
    return sb.toString();
  }
}
