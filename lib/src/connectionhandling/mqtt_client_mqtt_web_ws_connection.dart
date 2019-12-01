/*
 * Package : mqtt_client
 * Author : L. Casonato <hello@lcas.dev>
 * Date   : 01/12/2019
 * Copyright :  L. Casonato
 */

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:event_bus/event_bus.dart' as events;
import 'package:typed_data/typed_data.dart' as typed;
import '../exception/mqtt_client_noconnection_exception.dart';
import '../mqtt_client_connection_status.dart';
import '../utility/mqtt_client_byte_buffer.dart';
import '../utility/mqtt_client_logger.dart';
import './mqtt_client_mqtt_connection.dart';
import './mqtt_client_socket.dart';

/// The [WebSocket] implementation of [MqttSocket]
class MqttWebWebSocket implements MqttSocket {
  /// Default constructor
  MqttWebWebSocket(this.webSocket);

  /// The secure socket to use for communication
  WebSocket webSocket;

  /// Listen for messages on the socket
  @override
  void listen(void Function(List<int>) onData,
      {void Function(dynamic) onError, void Function() onDone}) {
    webSocket.onClose.listen((_) => onDone);
    webSocket.onError.listen(onError);
    webSocket.onMessage
        .map((message) => (message.data as ByteBuffer).asUint8List())
        .listen((data) => onData(data));
  }

  /// Add data to the socket
  @override
  void add(List<int> data) =>
      webSocket.sendByteBuffer(Uint8List.fromList(data).buffer);

  /// Close the socket
  @override
  Future<dynamic> close() {
    webSocket.close(0, 'CLOSING');
    return Future<void>.value();
  }
}

/// The MQTT connection class for the websocket interface
class MqttWebWsConnection extends MqttConnection {
  /// Default constructor
  MqttWebWsConnection(events.EventBus eventBus) : super(eventBus);

  /// Initializes a new instance of the MqttConnection class.
  MqttWebWsConnection.fromConnect(
      String server, int port, events.EventBus eventBus)
      : super(eventBus) {
    connect(server, port);
  }

  /// The websocket subprotocol list
  List<String> protocols = protocolsMultipleDefault;

  /// Connect
  @override
  Future<MqttClientConnectionStatus> connect(String server, int port) {
    final Completer<MqttClientConnectionStatus> completer =
        Completer<MqttClientConnectionStatus>();
    // Add the port if present
    Uri uri;
    try {
      uri = Uri.parse(server);
    } on Exception {
      final String message =
          'MqttWsConnection::The URI supplied for the WS connection is not valid - $server';
      throw NoConnectionException(message);
    }
    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      final String message =
          'MqttWsConnection::The URI supplied for the WS has an incorrect scheme - $server';
      throw NoConnectionException(message);
    }
    if (port != null) {
      uri = uri.replace(port: port);
    }
    final String uriString = uri.toString();
    MqttLogger.log(
        'MqttWsConnection:: WS URL is $uriString, protocols are $protocols');
    try {
      // Connect and save the socket.
      final WebSocket socket =
          WebSocket(uriString, protocols.isNotEmpty ? protocols : null);
      socket.onOpen.listen((Event event) {
        if (socket.readyState == 1) {
          socket.binaryType = 'arraybuffer';
          client = MqttWebWebSocket(socket);
          readWrapper = ReadWrapper();
          messageStream = MqttByteBuffer(typed.Uint8Buffer());
          startListening();
          completer.complete();
        }
      }).onError((dynamic e) {
        onError(e);
        completer.completeError(e);
      });
    } on Exception {
      final String message =
          'MqttWsConnection::The connection to the message broker {$uriString} could not be made.';
      throw NoConnectionException(message);
    }
    return completer.future;
  }
}
