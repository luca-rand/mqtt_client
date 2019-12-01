/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/06/2017
 * Copyright :  S.Hamblett
 */

import '../../encoding/mqtt_client_mqtt_encoding.dart';
import '../../exception/mqtt_client_client_identifier_exception.dart';
import '../../mqtt_client_constants.dart';
import '../../utility/mqtt_client_byte_buffer.dart';
import '../../utility/mqtt_client_logger.dart';
import '../mqtt_client_mqtt_payload.dart';
import './mqtt_client_mqtt_connect_variable_header.dart';

/// Class that contains details related to an MQTT Connect messages payload.
class MqttConnectPayload extends MqttPayload {
  /// Initializes a new instance of the MqttConnectPayload class.
  MqttConnectPayload(this.variableHeader);

  /// Initializes a new instance of the MqttConnectPayload class.
  MqttConnectPayload.fromByteBuffer(
      this.variableHeader, MqttByteBuffer payloadStream) {
    readFrom(payloadStream);
  }

  String _clientIdentifier = '';

  /// Client identifier
  String get clientIdentifier => _clientIdentifier;

  set clientIdentifier(String id) {
    if (id.length > Constants.maxClientIdentifierLength) {
      throw ClientIdentifierException(id);
    }
    if (id.length > Constants.maxClientIdentifierLengthSpec) {
      MqttLogger.log(
          'MqttConnectPayload::Client id exceeds spec value of ${Constants.maxClientIdentifierLengthSpec}');
    }
    _clientIdentifier = id;
  }

  /// Variable header
  MqttConnectVariableHeader variableHeader = MqttConnectVariableHeader();
  String _username;

  /// User name
  String get username => _username;

  set username(String name) => _username = name != null ? name.trim() : name;
  String _password;

  /// Password
  String get password => _password;

  set password(String pwd) => _password = pwd != null ? pwd.trim() : pwd;

  /// Will topic
  String willTopic;

  /// Will message
  String willMessage;

  /// Creates a payload from the specified header stream.
  @override
  void readFrom(MqttByteBuffer payloadStream) {
    clientIdentifier = payloadStream.readMqttStringM();
    if (variableHeader.connectFlags.willFlag) {
      willTopic = payloadStream.readMqttStringM();
      willMessage = payloadStream.readMqttStringM();
    }
    if (variableHeader.connectFlags.usernameFlag) {
      username = payloadStream.readMqttStringM();
    }
    if (variableHeader.connectFlags.passwordFlag) {
      password = payloadStream.readMqttStringM();
    }
  }

  /// Writes the connect message payload to the supplied stream.
  @override
  void writeTo(MqttByteBuffer payloadStream) {
    payloadStream.writeMqttStringM(clientIdentifier);
    if (variableHeader.connectFlags.willFlag) {
      payloadStream.writeMqttStringM(willTopic);
      payloadStream.writeMqttStringM(willMessage);
    }
    if (variableHeader.connectFlags.usernameFlag) {
      payloadStream.writeMqttStringM(username);
    }
    if (variableHeader.connectFlags.passwordFlag) {
      payloadStream.writeMqttStringM(password);
    }
  }

  @override
  int getWriteLength() {
    int length = 0;
    final MqttEncoding enc = MqttEncoding();
    length += enc.getByteCount(clientIdentifier);
    if (variableHeader.connectFlags.willFlag) {
      length += enc.getByteCount(willTopic);
      length += enc.getByteCount(willMessage);
    }
    if (variableHeader.connectFlags.usernameFlag) {
      length += enc.getByteCount(username);
    }
    if (variableHeader.connectFlags.passwordFlag) {
      length += enc.getByteCount(password);
    }
    return length;
  }
}
