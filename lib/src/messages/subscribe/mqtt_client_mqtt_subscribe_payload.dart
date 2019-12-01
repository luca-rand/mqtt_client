/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/06/2017
 * Copyright :  S.Hamblett
 */

import '../../encoding/mqtt_client_mqtt_encoding.dart';
import '../../mqtt_client_mqtt_qos.dart';
import '../../utility/mqtt_client_byte_buffer.dart';
import '../../utility/mqtt_client_utilities.dart';
import '../mqtt_client_mqtt_header.dart';
import '../mqtt_client_mqtt_payload.dart';
import '../mqtt_client_mqtt_variable_header.dart';

/// Class that contains details related to an MQTT Subscribe messages payload
class MqttSubscribePayload extends MqttPayload {
  /// Initializes a new instance of the MqttSubscribePayload class.
  MqttSubscribePayload();

  /// Initializes a new instance of the MqttSubscribePayload class.
  MqttSubscribePayload.fromByteBuffer(
      this.header, this.variableHeader, MqttByteBuffer payloadStream) {
    readFrom(payloadStream);
  }

  /// Variable header
  MqttVariableHeader variableHeader;

  /// Message header
  MqttHeader header;

  /// The collection of subscriptions, Key is the topic, Value is the qos
  Map<String, MqttQos> subscriptions = Map<String, MqttQos>();

  /// Writes the payload to the supplied stream.
  @override
  void writeTo(MqttByteBuffer payloadStream) {
    subscriptions.forEach((String key, MqttQos value) {
      payloadStream.writeMqttStringM(key);
      payloadStream.writeByte(value.index);
    });
  }

  /// Creates a payload from the specified header stream.
  @override
  void readFrom(MqttByteBuffer payloadStream) {
    int payloadBytesRead = 0;
    final int payloadLength = header.messageSize - variableHeader.length;
    // Read all the topics and qos subscriptions from the message payload
    while (payloadBytesRead < payloadLength) {
      final String topic = payloadStream.readMqttStringM();
      final MqttQos qos = MqttUtilities.getQosLevel(payloadStream.readByte());
      payloadBytesRead +=
          topic.length + 3; // +3 = Mqtt string length bytes + qos byte
      addSubscription(topic, qos);
    }
  }

  /// Gets the length of the payload in bytes when written to a stream.
  @override
  int getWriteLength() {
    int length = 0;
    final MqttEncoding enc = MqttEncoding();
    subscriptions.forEach((String key, MqttQos value) {
      length += enc.getByteCount(key);
      length += 1;
    });
    return length;
  }

  /// Adds a new subscription to the collection of subscriptions.
  void addSubscription(String topic, MqttQos qos) {
    subscriptions[topic] = qos;
  }

  /// Clears the subscriptions.
  void clearSubscriptions() {
    subscriptions.clear();
  }

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    sb.writeln('Payload: Subscription [{${subscriptions.length}}]');
    subscriptions.forEach((String key, MqttQos value) {
      sb.writeln('{{ Topic={$key}, Qos={$value} }}');
    });
    return sb.toString();
  }
}
