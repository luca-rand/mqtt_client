/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 10/07/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'dart:io';
import 'package:event_bus/event_bus.dart' as events;
import './connectionhandling/mqtt_client_connection_state.dart';
import './connectionhandling/mqtt_client_mqtt_connection_handler_secure.dart';
import './connectionhandling/mqtt_client_mqtt_connection_keep_alive.dart';
import './connectionhandling/mqtt_client_synchronous_mqtt_connection_handler_secure.dart';
import './messages/connect/mqtt_client_mqtt_connect_message.dart';
import './messages/connect/mqtt_client_mqtt_connect_return_code.dart';
import './mqtt_client.dart';
import './mqtt_client_connection_status.dart';
import './mqtt_client_constants.dart';
import './mqtt_client_mqtt_qos.dart';
import './mqtt_client_publishing_manager.dart';
import './mqtt_client_subscriptions_manager.dart';
import './utility/mqtt_client_logger.dart';

/// MqttClientSecure is a
class MqttClientSecure extends MqttClient {
  /// Initializes a new instance of the MqttClient class using the default Mqtt Port.
  /// The server hostname to connect to
  /// The client identifier to use to connect with
  MqttClientSecure(String server, String clientIdentifier)
      : super(server, clientIdentifier);

  /// Initializes a new instance of the MqttClient class using the supplied Mqtt Port.
  /// The server hostname to connect to
  /// The client identifier to use to connect with
  /// The port to use
  MqttClientSecure.withPort(String server, String clientIdentifier, int port)
      : super.withPort(server, clientIdentifier, port);

  /// If set use the alternate websocket implementation
  bool useAlternateWebSocketImplementation = false;

  /// The security context for secure usage
  SecurityContext securityContext = SecurityContext.defaultContext;

  /// Callback function to handle bad certificate. if true, ignore the error.
  bool Function(X509Certificate certificate) onBadCertificate;

  /// The event bus
  events.EventBus _clientEventBus;

  /// The Handler that is managing the connection to the remote server.
  MqttConnectionHandlerSecure _connectionHandler;

  /// The subscriptions manager responsible for tracking subscriptions.
  SubscriptionsManager _subscriptionsManager;

  /// Handles the connection management while idle.
  MqttConnectionKeepAlive _keepAlive;

  List<String> _websocketProtocols;

  /// Handles everything to do with publication management.
  PublishingManager _publishingManager;

  MqttClientConnectionStatus _connectionStatus = MqttClientConnectionStatus();

  @override
  Future<MqttClientConnectionStatus> connect(
      [String username, String password]) async {
    if (username != null) {
      MqttLogger.log(
          "Authenticating with username '{$username}' and password '{$password}'");
      if (username.trim().length >
          Constants.recommendedMaxUsernamePasswordLength) {
        MqttLogger.log(
            'Username length (${username.trim().length}) exceeds the max recommended in the MQTT spec. ');
      }
    }
    if (password != null &&
        password.trim().length >
            Constants.recommendedMaxUsernamePasswordLength) {
      MqttLogger.log(
          'Password length (${password.trim().length}) exceeds the max recommended in the MQTT spec. ');
    }
    // Set the authentication parameters in the connection message if we have one
    connectionMessage?.authenticateAs(username, password);

    // Do the connection
    _clientEventBus = events.EventBus();
    _connectionHandler =
        SynchronousMqttConnectionHandlerSecure(_clientEventBus);
    if (useWebSocket) {
      _connectionHandler.useWebSocket = true;
      _connectionHandler.useAlternateWebSocketImplementation =
          useAlternateWebSocketImplementation;
      if (_websocketProtocols != null) {
        _connectionHandler.websocketProtocols = _websocketProtocols;
      }
    }
    _connectionHandler.useWebSocket = false;
    _connectionHandler.useAlternateWebSocketImplementation = false;
    _connectionHandler.securityContext = securityContext;
    _connectionHandler.onBadCertificate = onBadCertificate;
    _connectionHandler.onDisconnected = _internalDisconnect;
    _connectionHandler.onConnected = onConnected;
    _publishingManager = PublishingManager(_connectionHandler, _clientEventBus);
    _subscriptionsManager = SubscriptionsManager(
        _connectionHandler, _publishingManager, _clientEventBus);
    _subscriptionsManager.onSubscribed = onSubscribed;
    _subscriptionsManager.onUnsubscribed = onUnsubscribed;
    _subscriptionsManager.onSubscribeFail = onSubscribeFail;
    updates = _subscriptionsManager.subscriptionNotifier.changes;
    _keepAlive = MqttConnectionKeepAlive(_connectionHandler, keepAlivePeriod);
    if (pongCallback != null) {
      _keepAlive.pongCallback = pongCallback;
    }
    final MqttConnectMessage connectMessage =
        _getConnectMessage(username, password);
    return await _connectionHandler.connect(server, port, connectMessage);
  }

  /// Internal disconnect
  /// This is always passed to the connection handler to allow the client to close itself
  /// down correctly on disconnect.
  void _internalDisconnect() {
    // Only call disconnect if we are connected, i.e. a connection to
    // the broker has been previously established.
    if (connectionStatus.state == MqttConnectionState.connected) {
      _disconnect(unsolicited: true);
    }
  }

  /// Actual disconnect processing
  void _disconnect({bool unsolicited = true}) {
    // Only disconnect the connection handler if the request is
    // solicited, unsolicited requests, ie broker termination don't
    // need this.
    MqttConnectReturnCode returnCode = MqttConnectReturnCode.unsolicited;
    if (!unsolicited) {
      _connectionHandler?.disconnect();
      returnCode = MqttConnectReturnCode.solicited;
    }
    _publishingManager?.published?.close();
    _publishingManager = null;
    _subscriptionsManager = null;
    _keepAlive?.stop();
    _keepAlive = null;
    _connectionHandler = null;
    _clientEventBus?.destroy();
    _clientEventBus = null;
    // Set the connection status before calling onDisconnected
    _connectionStatus.state = MqttConnectionState.disconnected;
    _connectionStatus.returnCode = returnCode;
    if (onDisconnected != null) {
      onDisconnected();
    }
  }

  ///  Gets a pre-configured connect message if one has not been supplied by the user.
  ///  Returns an MqttConnectMessage that can be used to connect to a message broker
  MqttConnectMessage _getConnectMessage(String username, String password) =>
      connectionMessage ??= MqttConnectMessage()
          .withClientIdentifier(clientIdentifier)
          // Explicitly set the will flag
          .withWillQos(MqttQos.atMostOnce)
          .keepAliveFor(Constants.defaultKeepAlive)
          .authenticateAs(username, password)
          .startClean();
}
