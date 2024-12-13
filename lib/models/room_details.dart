import 'dart:convert';

class RoomDetails {
  final Room? room;
  final bool? success;

  RoomDetails({
    this.room,
    this.success,
  });

  factory RoomDetails.fromMap(Map<String, dynamic> map) {
    return RoomDetails(
      room: map['room'] != null ? Room.fromMap(map['room']) : null,
      success: map['success'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'room': room?.toMap(),
      'success': success,
    };
  }
}

class Room {
  final String? id;
  final String? ts;
  final String? t;
  final String? name;
  final List<dynamic>? usernames;
  final int? msgs;
  final int? usersCount;
  final String? updatedAt;
  final User? u;
  final bool? isDefault;
  final LastMessage? lastMessage;
  final String? lm;

  Room({
    this.id,
    this.ts,
    this.t,
    this.name,
    this.usernames,
    this.msgs,
    this.usersCount,
    this.updatedAt,
    this.u,
    this.isDefault,
    this.lastMessage,
    this.lm,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['_id'],
      ts: map['ts'],
      t: map['t'],
      name: map['name'],
      usernames: List<dynamic>.from(map['usernames'] ?? []),
      msgs: map['msgs'],
      usersCount: map['usersCount'],
      updatedAt: map['_updatedAt'],
      u: map['u'] != null ? User.fromMap(map['u']) : null,
      isDefault: map['default'],
      lastMessage: map['lastMessage'] != null ? LastMessage.fromMap(map['lastMessage']) : null,
      lm: map['lm'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'ts': ts,
      't': t,
      'name': name,
      'usernames': usernames,
      'msgs': msgs,
      'usersCount': usersCount,
      '_updatedAt': updatedAt,
      'u': u?.toMap(),
      'default': isDefault,
      'lastMessage': lastMessage?.toMap(),
      'lm': lm,
    };
  }
}

class User {
  final String? id;
  final String? username;
  final String? name;

  User({
    this.id,
    this.username,
    this.name,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      username: map['username'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'name': name,
    };
  }
}

class LastMessage {
  final String? id;
  final String? t;
  final String? rid;
  final String? ts;
  final String? msg;
  final User? u;
  final bool? groupable;
  final String? drid;
  final String? updatedAt;

  LastMessage({
    this.id,
    this.t,
    this.rid,
    this.ts,
    this.msg,
    this.u,
    this.groupable,
    this.drid,
    this.updatedAt,
  });

  factory LastMessage.fromMap(Map<String, dynamic> map) {
    return LastMessage(
      id: map['_id'],
      t: map['t'],
      rid: map['rid'],
      ts: map['ts'],
      msg: map['msg'],
      u: map['u'] != null ? User.fromMap(map['u']) : null,
      groupable: map['groupable'],
      drid: map['drid'],
      updatedAt: map['_updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      't': t,
      'rid': rid,
      'ts': ts,
      'msg': msg,
      'u': u?.toMap(),
      'groupable': groupable,
      'drid': drid,
      '_updatedAt': updatedAt,
    };
  }
}