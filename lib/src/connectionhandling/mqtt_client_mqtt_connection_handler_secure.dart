/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 22/06/2017
 * Copyright :  S.Hamblett
 */

import 'dart:io';
import './mqtt_client_mqtt_connection_handler.dart';

///  This class provides shared connection functionality to connection handler implementations.
abstract class MqttConnectionHandlerSecure extends MqttConnectionHandler {
  /// Initializes a new instance of the MqttConnectionHandler class.
  MqttConnectionHandlerSecure();

  /// The security context for secure usage
  SecurityContext securityContext;

  /// Callback function to handle bad certificate. if true, ignore the error.
  bool Function(X509Certificate certificate) onBadCertificate;

  /// Alternate websocket implementation.
  ///
  /// The Amazon Web Services (AWS) IOT MQTT interface(and maybe others) has a bug that causes it
  /// not to connect if unexpected message headers are present in the initial GET message during the handshake.
  /// Since the httpclient classes insist on adding those headers, an alternate method is used to perform the handshake.
  /// After the handshake everything goes back to the normal websocket class.
  /// Only use this websocket implementation if you know it is needed by your broker.
  bool useAlternateWebSocketImplementation = false;
}
