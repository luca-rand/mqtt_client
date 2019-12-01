/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/10/2017
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
import '../utility/mqtt_client_logger.dart';
import './mqtt_client_mqtt_connection.dart';
import './mqtt_client_socket.dart';

/// The [SecureSocket] implementation of [MqttSocket]
class MqttSecureSocket implements MqttSocket {
  /// Default constructor
  MqttSecureSocket(this.secureSocket);

  /// The secure socket to use for communication
  SecureSocket secureSocket;

  /// Listen for messages on the socket
  @override
  StreamSubscription<Uint8List> listen(void Function(List<int>) onData,
          {void Function(dynamic) onError, void Function() onDone}) =>
      secureSocket.listen(onData, onError: onError, onDone: onDone);

  /// Add data to the socket
  @override
  void add(List<int> data) => secureSocket.add(data);

  /// Close the socket
  @override
  Future<dynamic> close() => secureSocket.close();
}

/// The MQTT secure connection class
class MqttSecureConnection extends MqttConnection {
  /// Default constructor
  MqttSecureConnection(
      this.context, events.EventBus eventBus, this.onBadCertificate)
      : super(eventBus);

  /// Initializes a new instance of the MqttSecureConnection class.
  MqttSecureConnection.fromConnect(
      String server, int port, events.EventBus eventBus)
      : super(eventBus) {
    connect(server, port);
  }

  /// The security context for secure usage
  SecurityContext context;

  /// Callback function to handle bad certificate. if true, ignore the error.
  bool Function(X509Certificate certificate) onBadCertificate;

  /// Connect
  @override
  Future<MqttClientConnectionStatus> connect(String server, int port) {
    final Completer<MqttClientConnectionStatus> completer =
        Completer<MqttClientConnectionStatus>();
    MqttLogger.log('MqttSecureConnection::connect');
    try {
      SecureSocket.connect(server, port,
              onBadCertificate: onBadCertificate, context: context)
          .then((SecureSocket socket) {
        MqttLogger.log('MqttSecureConnection::connect - securing socket');
        client = MqttSecureSocket(socket);
        readWrapper = ReadWrapper();
        messageStream = MqttByteBuffer(typed.Uint8Buffer());
        MqttLogger.log('MqttSecureConnection::connect - start listening');
        startListening();
        completer.complete();
      }).catchError((dynamic e) {
        onError(e);
        completer.completeError(e);
      });
    } on SocketException catch (e) {
      final String message =
          'MqttSecureConnection::The connection to the message broker {$server}:{$port} could not be made. Error is ${e.toString()}';
      completer.completeError(e);
      throw NoConnectionException(message);
    } on HandshakeException catch (e) {
      final String message =
          'MqttSecureConnection::Handshake exception to the message broker {$server}:{$port}. Error is ${e.toString()}';
      completer.completeError(e);
      throw NoConnectionException(message);
    } on TlsException catch (e) {
      final String message =
          'MqttSecureConnection::TLS exception raised on secure connection. Error is ${e.toString()}';
      throw NoConnectionException(message);
    }
    return completer.future;
  }
}
