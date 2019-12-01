/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 15/06/2017
 * Copyright :  S.Hamblett
 */

import '../exception/mqtt_client_invalid_header_exception.dart';
import '../messages/mqtt_client_mqtt_message_type.dart';
import '../utility/mqtt_client_byte_buffer.dart';
import './connect/mqtt_client_mqtt_connect_message.dart';
import './connectack/mqtt_client_mqtt_connect_ack_message.dart';
import './disconnect/mqtt_client_mqtt_disconnect_message.dart';
import './mqtt_client_mqtt_header.dart';
import './mqtt_client_mqtt_message.dart';
import './pingrequest/mqtt_client_mqtt_ping_request_message.dart';
import './pingresponse/mqtt_client_mqtt_ping_response_message.dart';
import './publish/mqtt_client_mqtt_publish_message.dart';
import './publishack/mqtt_client_mqtt_publish_ack_message.dart';
import './publishcomplete/mqtt_client_mqtt_publish_complete_message.dart';
import './publishreceived/mqtt_client_mqtt_publish_received_message.dart';
import './publishrelease/mqtt_client_mqtt_publish_release_message.dart';
import './subscribe/mqtt_client_mqtt_subscribe_message.dart';
import './subscribeack/mqtt_client_mqtt_subscribe_ack_message.dart';
import './unsubscribe/mqtt_client_mqtt_unsubscribe_message.dart';
import './unsubscribeack/mqtt_client_mqtt_unsubscribe_ack_message.dart';

/// Factory for generating instances of MQTT Messages
class MqttMessageFactory {
  /// Gets an instance of an MqttMessage based on the message type requested.
  static MqttMessage getMessage(
      MqttHeader header, MqttByteBuffer messageStream) {
    MqttMessage message;
    switch (header.messageType) {
      case MqttMessageType.connect:
        message = MqttConnectMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.connectAck:
        message = MqttConnectAckMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.publish:
        message = MqttPublishMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.publishAck:
        message = MqttPublishAckMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.publishComplete:
        message =
            MqttPublishCompleteMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.publishReceived:
        message =
            MqttPublishReceivedMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.publishRelease:
        message =
            MqttPublishReleaseMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.subscribe:
        message = MqttSubscribeMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.subscribeAck:
        message = MqttSubscribeAckMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.unsubscribe:
        message = MqttUnsubscribeMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.unsubscribeAck:
        message =
            MqttUnsubscribeAckMessage.fromByteBuffer(header, messageStream);
        break;
      case MqttMessageType.pingRequest:
        message = MqttPingRequestMessage.fromHeader(header);
        break;
      case MqttMessageType.pingResponse:
        message = MqttPingResponseMessage.fromHeader(header);
        break;
      case MqttMessageType.disconnect:
        message = MqttDisconnectMessage.fromHeader(header);
        break;
      default:
        throw InvalidHeaderException(
            'The Message Type specified ($header.messageType) is not a valid '
            'MQTT Message type or currently not supported.');
    }
    return message;
  }
}
