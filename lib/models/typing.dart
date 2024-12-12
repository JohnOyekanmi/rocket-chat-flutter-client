class Typing {
  final String username;
  final bool isTyping;

  Typing({
    required this.username,
    required this.isTyping,
  });

  factory Typing.fromList(List<dynamic> data) {
    return Typing(
      username: data[0] as String,
      isTyping: data[1] as bool,
    );
  }

  @override
  String toString() => '$username is ${isTyping ? "typing" : "not typing"}';
}
