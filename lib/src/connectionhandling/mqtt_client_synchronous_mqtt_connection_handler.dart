/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 22/06/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'package:event_bus/event_bus.dart' as events;
import '../exception/mqtt_client_connection_type_not_supported.dart';
import '../exception/mqtt_client_noconnection_exception.dart';
import '../messages/connect/mqtt_client_mqtt_connect_message.dart';
import '../messages/connect/mqtt_client_mqtt_connect_return_code.dart';
import '../messages/connectack/mqtt_client_mqtt_connect_ack_message.dart';
import '../messages/disconnect/mqtt_client_mqtt_disconnect_message.dart';
import '../messages/mqtt_client_mqtt_message.dart';
import '../messages/mqtt_client_mqtt_message_type.dart';
import '../mqtt_client_connection_status.dart';
import '../mqtt_client_events.dart';
import '../utility/mqtt_client_logger.dart';
import '../utility/mqtt_client_utilities.dart';
import './mqtt_client_connection_state.dart';
import './mqtt_client_mqtt_connection_handler.dart';
import 'io.dart' if (dart.library.js) 'web.dart';

/// Connection handler that performs connections and disconnections to the hostname in a synchronous manner.
class SynchronousMqttConnectionHandler extends MqttConnectionHandler {
  /// Initializes a new instance of the MqttConnectionHandler class.
  SynchronousMqttConnectionHandler(this._clientEventBus);

  /// Max connection attempts
  static const int maxConnectionAttempts = 3;

  /// The broker connection acknowledgment timer
  MqttCancellableAsyncSleep _connectTimer;

  /// The event bus
  events.EventBus _clientEventBus;

  /// Synchronously connect to the specific Mqtt Connection.
  @override
  Future<MqttClientConnectionStatus> internalConnect(
      String hostname, int port, MqttConnectMessage connectMessage) async {
    int connectionAttempts = 0;
    MqttLogger.log('SynchronousMqttConnectionHandler::internalConnect entered');
    do {
      // Initiate the connection
      MqttLogger.log(
          'SynchronousMqttConnectionHandler::internalConnect - initiating connection try $connectionAttempts');
      connectionStatus.state = MqttConnectionState.connecting;
      if (isWeb) {
        if (useWebSocket) {
          MqttLogger.log(
              'SynchronousMqttConnectionHandler::internalConnect - websocket selected');
          connection = MqttWebWsConnection(_clientEventBus);
          if (websocketProtocols != null) {
            connection.protocols = websocketProtocols;
          }
        } else {
          MqttLogger.log(
              'SynchronousMqttConnectionHandler::internalConnect - insecure TCP selected');
          throw ConnectionTypeNotSupportedException('insecure TCP');
        }
      } else {
        if (useWebSocket) {
          MqttLogger.log(
              'SynchronousMqttConnectionHandler::internalConnect - websocket selected');
          connection = MqttWsConnection(_clientEventBus);
          if (websocketProtocols != null) {
            connection.protocols = websocketProtocols;
          }
        } else {
          MqttLogger.log(
              'SynchronousMqttConnectionHandler::internalConnect - insecure TCP selected');
          connection = MqttNormalConnection(_clientEventBus);
        }
      }
      connection.onDisconnected = onDisconnected;

      // Connect
      _connectTimer = MqttCancellableAsyncSleep(5000);
      await connection.connect(hostname, port);
      registerForMessage(MqttMessageType.connectAck, _connectAckProcessor);
      _clientEventBus.on<MessageAvailable>().listen(messageAvailable);
      // Transmit the required connection message to the broker.
      MqttLogger.log(
          'SynchronousMqttConnectionHandler::internalConnect sending connect message');
      sendMessage(connectMessage);
      MqttLogger.log(
          'SynchronousMqttConnectionHandler::internalConnect - pre sleep, state = $connectionStatus');
      // We're the sync connection handler so we need to wait for the brokers acknowledgement of the connections
      await _connectTimer.sleep();
      MqttLogger.log(
          'SynchronousMqttConnectionHandler::internalConnect - post sleep, state = $connectionStatus');
    } while (connectionStatus.state != MqttConnectionState.connected &&
        ++connectionAttempts < maxConnectionAttempts);
    // If we've failed to handshake with the broker, throw an exception.
    if (connectionStatus.state != MqttConnectionState.connected) {
      MqttLogger.log(
          'SynchronousMqttConnectionHandler::internalConnect failed');
      throw NoConnectionException(
          'The maximum allowed connection attempts ({$maxConnectionAttempts}) were exceeded. '
          'The broker is not responding to the connection request message '
          '(Missing Connection Acknowledgement');
    }
    MqttLogger.log(
        'SynchronousMqttConnectionHandler::internalConnect exited with state $connectionStatus');
    return connectionStatus;
  }

  /// Disconnects
  @override
  MqttConnectionState disconnect() {
    MqttLogger.log('SynchronousMqttConnectionHandler::disconnect');
    // Send a disconnect message to the broker
    connectionStatus.state = MqttConnectionState.disconnecting;
    sendMessage(MqttDisconnectMessage());
    _performConnectionDisconnect();
    return connectionStatus.state = MqttConnectionState.disconnected;
  }

  /// Disconnects the underlying connection object.
  void _performConnectionDisconnect() {
    connectionStatus.state = MqttConnectionState.disconnected;
  }

  /// Processes the connect acknowledgement message.
  bool _connectAckProcessor(MqttMessage msg) {
    MqttLogger.log('SynchronousMqttConnectionHandler::_connectAckProcessor');
    try {
      final MqttConnectAckMessage ackMsg = msg;
      // Drop the connection if our connect request has been rejected.
      if (ackMsg.variableHeader.returnCode ==
              MqttConnectReturnCode.brokerUnavailable ||
          ackMsg.variableHeader.returnCode ==
              MqttConnectReturnCode.identifierRejected ||
          ackMsg.variableHeader.returnCode ==
              MqttConnectReturnCode.unacceptedProtocolVersion ||
          ackMsg.variableHeader.returnCode ==
              MqttConnectReturnCode.notAuthorized ||
          ackMsg.variableHeader.returnCode ==
              MqttConnectReturnCode.badUsernameOrPassword) {
        MqttLogger.log(
            'SynchronousMqttConnectionHandler::_connectAckProcessor connection rejected');
        connectionStatus.returnCode = ackMsg.variableHeader.returnCode;
        _performConnectionDisconnect();
      } else {
        // Initialize the keepalive to start the ping based keepalive process.
        MqttLogger.log(
            'SynchronousMqttConnectionHandler::_connectAckProcessor - state = connected');
        connectionStatus.state = MqttConnectionState.connected;
        connectionStatus.returnCode = MqttConnectReturnCode.connectionAccepted;
        // Call the connected callback if we have one
        if (onConnected != null) {
          onConnected();
        }
      }
    } on Exception {
      _performConnectionDisconnect();
    }
    // Cancel the connect timer;
    MqttLogger.log(
        'SynchronousMqttConnectionHandler:: cancelling connect timer');
    _connectTimer.cancel();
    return true;
  }
}
