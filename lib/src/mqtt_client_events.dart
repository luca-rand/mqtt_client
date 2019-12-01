/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 22/06/2017
 * Copyright :  S.Hamblett
 */

import './messages/mqtt_client_mqtt_message.dart';
import './mqtt_client_publication_topic.dart';

/// The message available event raised by the Connection class
class MessageAvailable {
  /// Constructor
  MessageAvailable(this._message);

  /// The message associated with the event
  MqttMessage _message;

  /// Message
  MqttMessage get message => _message;
}

/// Message recieved class for publishing
class MessageReceived {
  /// Constructor
  MessageReceived(this._topic, this._message);

  /// The message associated with the event
  MqttMessage _message;

  /// Message
  MqttMessage get message => _message;

  /// The topic
  PublicationTopic _topic;

  /// Topic
  PublicationTopic get topic => _topic;
}
