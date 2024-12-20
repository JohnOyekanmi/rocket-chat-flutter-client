import 'package:rocket_chat_flutter_client/models/user.dart';

class Authentication {
  String? status;
  _Data? data;

  Authentication({this.status, this.data});

  Authentication.fromMap(Map<String, dynamic>? json) {
    if (json != null) {
      status = json['status'];
      data = json['data'] != null ? _Data.fromMap(json['data']) : null;
    }
  }

  Authentication copyWith({User? me, String? status}) {
    return Authentication(
      status: status ?? this.status,
      data: _Data(
        authToken: data?.authToken,
        userId: data?.userId,
        me: me ?? data?.me,
      ),
    );
  }

  static Authentication fakeAuth(String authToken, String userId) {
    return Authentication.fromMap({
      'status': 'success',
      'data': {
        'authToken': authToken,
        'userId': userId,
      }
    });
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'data': data != null ? data!.toMap() : null,
      };

  @override
  String toString() {
    return 'Authentication{status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authentication &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;
}

class _Data {
  String? authToken;
  String? userId;
  User? me;

  _Data({
    this.authToken,
    this.userId,
    this.me,
  });

  _Data.fromMap(Map<String, dynamic>? json) {
    if (json != null) {
      authToken = json['authToken'];
      userId = json['userId'];
      me = json['me'] != null ? User.fromMap(json['me']) : null;
    }
  }

  Map<String, dynamic> toMap() => {
        'authToken': authToken,
        'userId': userId,
        'me': me != null ? me!.toMap() : null,
      };

  @override
  String toString() {
    return '_Data{authToken: $authToken, userId: $userId, me: $me}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Data &&
          runtimeType == other.runtimeType &&
          authToken == other.authToken &&
          userId == other.userId &&
          me == other.me;

  @override
  int get hashCode => authToken.hashCode ^ userId.hashCode ^ me.hashCode;
}
