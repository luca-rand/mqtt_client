/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/06/2017
 * Copyright :  S.Hamblett
 */

import '../../mqtt_client_mqtt_qos.dart';
import '../../utility/mqtt_client_byte_buffer.dart';
import '../mqtt_client_mqtt_header.dart';
import '../mqtt_client_mqtt_message.dart';
import '../mqtt_client_mqtt_message_type.dart';
import './mqtt_client_mqtt_publish_release_variable_header.dart';

/// Implementation of an MQTT Publish Release Message.
class MqttPublishReleaseMessage extends MqttMessage {
  /// Initializes a new instance of the MqttPublishReleaseMessage class.
  MqttPublishReleaseMessage() {
    header = MqttHeader().asType(MqttMessageType.publishRelease);
    // Qos is specified for this message
    header.qos = MqttQos.atLeastOnce;
    variableHeader = MqttPublishReleaseVariableHeader();
  }

  /// Initializes a new instance of the MqttPublishReleaseMessage class.
  MqttPublishReleaseMessage.fromByteBuffer(
      MqttHeader header, MqttByteBuffer messageStream) {
    this.header = header;
    variableHeader =
        MqttPublishReleaseVariableHeader.fromByteBuffer(messageStream);
  }

  /// Gets or sets the variable header contents. Contains extended metadata about the message
  MqttPublishReleaseVariableHeader variableHeader;

  /// Writes the message to the supplied stream.
  @override
  void writeTo(MqttByteBuffer messageStream) {
    header.writeTo(variableHeader.getWriteLength(), messageStream);
    variableHeader.writeTo(messageStream);
  }

  /// Sets the message identifier of the MqttMessage.
  MqttPublishReleaseMessage withMessageIdentifier(int messageIdentifier) {
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
