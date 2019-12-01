/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import './mqtt_client_mqtt_qos.dart';
import './mqtt_client_subscription_topic.dart';
import './observable/observable.dart' as observe;

/// Entity that captures data related to an individual subscription
class Subscription extends Object
    with observe.Observable<observe.ChangeRecord> {
  /// The message identifier assigned to the subscription
  int messageIdentifier;

  /// The time the subscription was created.
  DateTime createdTime;

  /// The Topic that is subscribed to.
  SubscriptionTopic topic;

  /// The QOS level of the topics subscription
  MqttQos qos;
}
