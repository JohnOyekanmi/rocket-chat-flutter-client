class RoomNewResponse {
  String roomId;
  bool success;

  RoomNewResponse({
    required this.roomId,
    required this.success,
  });

  factory RoomNewResponse.fromMap(Map<String, dynamic> json) {
    return RoomNewResponse(
      roomId: json['room']['rid'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toMap() => {
        'rid': roomId,
        'success': success,
      };

  @override
  String toString() {
    return 'RoomNewResponse{roomId: $roomId, success: $success}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomNewResponse &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId &&
          success == other.success;

  @override
  int get hashCode => roomId.hashCode ^ success.hashCode;
}
