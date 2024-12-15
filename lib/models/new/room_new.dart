class RoomNew {
  final String username;

  RoomNew({
    required this.username,
  });

  factory RoomNew.fromMap(Map<String, dynamic> json) {
    return RoomNew(username: json['username']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['username'] = username;

    return map;
  }

  @override
  String toString() {
    return 'RoomNew{username: $username}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomNew &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}
