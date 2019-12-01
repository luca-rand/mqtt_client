/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import './mqtt_client_constants.dart';

/// Protocol selection helper class, protocol defaults V3.1
class Protocol {
  /// Version
  static int version = Constants.mqttV31ProtocolVersion;

  /// Name
  static String name = Constants.mqttV31ProtocolName;
}
