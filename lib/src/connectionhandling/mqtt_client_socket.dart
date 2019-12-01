/*
 * Package : mqtt_client
 * Author : L. Casonato <hello@lcas.dev>
 * Date   : 01/12/2019
 * Copyright :  L. Casonato
 */

import 'dart:async';
import 'dart:typed_data';

/// The socket used for communication
abstract class MqttSocket {
  /// Listen for messages on the socket
  StreamSubscription<Uint8List> listen(void Function(List<int>) onData,
          {void Function(dynamic) onError, void Function() onDone}) =>
      null;

  /// Add data to the socket
  void add(List<int> data) {}

  /// Close the socket
  Future<dynamic> close() => null;
}
