/*
 * Package : mqtt_client
 * Author : L. Casonato <hello@lcas.dev>
 * Date   : 01/12/2019
 * Copyright :  L. Casonato
 */

/// Exception thrown when a connection type is not supported
class ConnectionTypeNotSupportedException implements Exception {
  /// Construct
  ConnectionTypeNotSupportedException(String connenctionType) {
    _message =
        'mqtt-client::ConnectionTypeNotSupportedException: The connection type \'$connenctionType\' is not supported on the current platform.';
  }

  String _message;

  @override
  String toString() => _message;
}
