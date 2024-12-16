import 'package:collection/collection.dart';
import 'package:rocket_chat_flutter_client/models/message.dart';
import 'package:rocket_chat_flutter_client/models/user.dart';

class Room {
  String? id;
  DateTime? updatedAt;
  String? t;
  int? msgs;
  DateTime? ts;
  DateTime? lm;
  String? topic;
  String? rid;
  List<String>? usernames;
  // Added missing fields
  String? name;
  int? usersCount;
  User? u;
  bool? isDefault;
  Message? lastMessage;

  Room({
    this.id,
    this.updatedAt,
    this.t,
    this.msgs,
    this.ts,
    this.lm,
    this.topic,
    this.rid,
    this.usernames,
    // Added missing fields in constructor
    this.name,
    this.usersCount,
    this.u,
    this.isDefault,
    this.lastMessage,
  });

  factory Room.fromMap(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      rid: json['rid'],
      updatedAt: json['_updatedAt'] != null
          ? DateTime.parse(json['_updatedAt'])
          : null,
      t: json['t'],
      msgs: json['msgs'],
      ts: json['ts'] != null ? DateTime.parse(json['ts']) : null,
      lm: json['lm'] != null ? DateTime.parse(json['lm']) : null,
      topic: json['topic'],
      usernames: json['usernames'] != null
          ? List<String>.from(json['usernames'])
          : null,
      // Added missing fields parsing
      name: json['name'],
      usersCount: json['usersCount'],
      u: json['u'] != null ? User.fromMap(json['u']) : null,
      isDefault: json['default'],
      lastMessage: json['lastMessage'] != null
          ? Message.fromMap(json['lastMessage'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (id != null) map['_id'] = id;
    if (rid != null) map['rid'] = rid;
    if (updatedAt != null) map['_updatedAt'] = updatedAt!.toIso8601String();
    if (t != null) map['t'] = t;
    if (msgs != null) map['msgs'] = msgs;
    if (ts != null) map['ts'] = ts!.toIso8601String();
    if (lm != null) map['lm'] = lm!.toIso8601String();
    if (topic != null) map['topic'] = topic;
    if (usernames != null) map['usernames'] = usernames;
    // Added missing fields to map
    if (name != null) map['name'] = name;
    if (usersCount != null) map['usersCount'] = usersCount;
    if (u != null) map['u'] = u!.toMap();
    if (isDefault != null) map['default'] = isDefault;
    if (lastMessage != null) map['lastMessage'] = lastMessage!.toMap();
    return map;
  }

  @override
  String toString() {
    return 'Room{id: $id, updatedAt: $updatedAt, t: $t, msgs: $msgs, ts: $ts, '
        'lm: $lm, topic: $topic, rid: $rid, usernames: $usernames, '
        'name: $name, usersCount: $usersCount, u: $u, '
        'isDefault: $isDefault, lastMessage: $lastMessage}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updatedAt == other.updatedAt &&
          t == other.t &&
          msgs == other.msgs &&
          ts == other.ts &&
          lm == other.lm &&
          topic == other.topic &&
          rid == other.rid &&
          DeepCollectionEquality().equals(usernames, other.usernames) &&
          name == other.name &&
          usersCount == other.usersCount &&
          u == other.u &&
          isDefault == other.isDefault &&
          lastMessage == other.lastMessage;

  @override
  int get hashCode =>
      id.hashCode ^
      updatedAt.hashCode ^
      t.hashCode ^
      msgs.hashCode ^
      ts.hashCode ^
      lm.hashCode ^
      topic.hashCode ^
      rid.hashCode ^
      usernames.hashCode ^
      name.hashCode ^
      usersCount.hashCode ^
      u.hashCode ^
      isDefault.hashCode ^
      lastMessage.hashCode;
}
