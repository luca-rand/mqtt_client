/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import './connectionhandling/mqtt_client_connection_state.dart';
import './messages/connect/mqtt_client_mqtt_connect_return_code.dart';

/// Records the status of the last connection attempt
class MqttClientConnectionStatus {
  /// Connection state
  MqttConnectionState state = MqttConnectionState.disconnected;

  /// Return code
  MqttConnectReturnCode returnCode = MqttConnectReturnCode.noneSpecified;

  @override
  String toString() {
    final String s = state.toString().split('.')[1];
    final String r = returnCode.toString().split('.')[1];
    return 'Connection status is $s with return code $r';
  }
}
