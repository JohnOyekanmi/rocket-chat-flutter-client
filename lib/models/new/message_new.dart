import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rocket_chat_flutter_client/models/message_attachment.dart';

class MessageNew {
  String? id;
  String? alias;
  String? avatar;
  String? emoji;
  String? roomId;
  String? message;
  List<MessageAttachment>? attachments;

  MessageNew({
    this.id,
    this.alias,
    this.avatar,
    this.emoji,
    this.roomId,
    this.message,
    this.attachments,
  });

  MessageNew.fromMap(Map<String, dynamic>? json) {
    if (json != null) {
      id = json['_id'];
      alias = json['alias'];
      avatar = json['avatar'];
      emoji = json['emoji'];
      roomId = json['rid'];
      message = json['msg'];

      if (json['attachments'] != null) {
        List<dynamic> jsonList = json['attachments'].runtimeType == String //
            ? jsonDecode(json['attachments'])
            : json['attachments'];
        attachments = jsonList
            .where((json) => json != null)
            .map((json) => MessageAttachment.fromMap(json))
            .toList();
      } else {
        attachments = null;
      }
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      '_id': id,
      'rid': roomId,
      'msg': message,
    };

    if (alias != null) {
      map['alias'] = alias;
    }
    if (emoji != null) {
      map['emoji'] = emoji;
    }
    if (avatar != null) {
      map['avatar'] = avatar;
    }
    if (attachments != null) {
      map['attachments'] = attachments
              ?.where((json) => json != null)
              .map((attachment) => attachment.toMap())
              .toList() ??
          [];
    }

    return map;
  }

  @override
  String toString() {
    return 'MessageNew{alias: $alias, avatar: $avatar, emoji: $emoji, roomId: $roomId, message: $message, attachments: $attachments}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageNew &&
          runtimeType == other.runtimeType &&
          alias == other.alias &&
          avatar == other.avatar &&
          emoji == other.emoji &&
          roomId == other.roomId &&
          message == other.message &&
          DeepCollectionEquality().equals(attachments, other.attachments);

  @override
  int get hashCode =>
      alias.hashCode ^
      avatar.hashCode ^
      emoji.hashCode ^
      roomId.hashCode ^
      message.hashCode ^
      attachments.hashCode;
}
