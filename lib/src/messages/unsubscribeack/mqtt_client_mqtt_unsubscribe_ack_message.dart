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
import './mqtt_client_mqtt_unsubscribe_ack_variable_header.dart';

/// Implementation of an MQTT Unsubscribe Ack Message.
class MqttUnsubscribeAckMessage extends MqttMessage {
  /// Initializes a new instance of the MqttUnsubscribeAckMessage class.
  MqttUnsubscribeAckMessage() {
    header = MqttHeader().asType(MqttMessageType.unsubscribeAck);
    variableHeader = MqttUnsubscribeAckVariableHeader();
  }

  /// Initializes a new instance of the MqttUnsubscribeAckMessage class.
  MqttUnsubscribeAckMessage.fromByteBuffer(
      MqttHeader header, MqttByteBuffer messageStream) {
    this.header = header;
    readFrom(messageStream);
  }

  /// Gets or sets the variable header contents. Contains extended metadata about the message
  MqttUnsubscribeAckVariableHeader variableHeader;

  /// Writes the message to the supplied stream.
  @override
  void writeTo(MqttByteBuffer messageStream) {
    header.writeTo(variableHeader.getWriteLength(), messageStream);
    variableHeader.writeTo(messageStream);
  }

  /// Reads a message from the supplied stream.
  @override
  void readFrom(MqttByteBuffer messageStream) {
    variableHeader =
        MqttUnsubscribeAckVariableHeader.fromByteBuffer(messageStream);
  }

  /// Sets the message identifier on the subscribe message.
  MqttUnsubscribeAckMessage withMessageIdentifier(int messageIdentifier) {
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
