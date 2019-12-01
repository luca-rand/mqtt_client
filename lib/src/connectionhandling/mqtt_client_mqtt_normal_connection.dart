/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 22/06/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:event_bus/event_bus.dart' as events;
import 'package:typed_data/typed_data.dart' as typed;
import '../exception/mqtt_client_noconnection_exception.dart';
import '../mqtt_client_connection_status.dart';
import '../utility/mqtt_client_byte_buffer.dart';
import './mqtt_client_mqtt_connection.dart';
import './mqtt_client_socket.dart';

/// The [Socket] implementation of [MqttSocket]
class MqttNormalSocket implements MqttSocket {
  /// Default constructor
  MqttNormalSocket(this.socket);

  /// The secure socket to use for communication
  Socket socket;

  /// Listen for messages on the socket
  @override
  StreamSubscription<Uint8List> listen(void Function(List<int>) onData,
          {void Function(dynamic) onError, void Function() onDone}) =>
      socket.listen(onData, onError: onError, onDone: onDone);

  /// Add data to the socket
  @override
  void add(List<int> data) => socket.add(data);

  /// Close the socket
  @override
  Future<dynamic> close() => socket.close();
}

/// The MQTT normal(insecure TCP) connection class
class MqttNormalConnection extends MqttConnection {
  /// Default constructor
  MqttNormalConnection(events.EventBus eventBus) : super(eventBus);

  /// Initializes a new instance of the MqttConnection class.
  MqttNormalConnection.fromConnect(
      String server, int port, events.EventBus eventBus)
      : super(eventBus) {
    connect(server, port);
  }

  /// Connect - overridden
  @override
  Future<MqttClientConnectionStatus> connect(String server, int port) {
    final Completer<MqttClientConnectionStatus> completer =
        Completer<MqttClientConnectionStatus>();
    try {
      // Connect and save the socket.
      Socket.connect(server, port).then((dynamic socket) {
        client = MqttNormalSocket(socket);
        readWrapper = ReadWrapper();
        messageStream = MqttByteBuffer(typed.Uint8Buffer());
        startListening();
        completer.complete();
      }).catchError((dynamic e) {
        onError(e);
        completer.completeError(e);
      });
    } on Exception catch (e) {
      completer.completeError(e);
      final String message =
          'MqttNormalConnection::The connection to the message broker {$server}:{$port} could not be made.';
      throw NoConnectionException(message);
    }
    return completer.future;
  }
}
