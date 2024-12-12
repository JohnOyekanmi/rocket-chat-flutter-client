class MediaMetadata {
  final String id;
  final String url;

  MediaMetadata({
    required this.id,
    required this.url,
  });

  factory MediaMetadata.fromMap(Map<String, dynamic> json) {
    return MediaMetadata(
      id: json['_id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toMap() => {
        '_id': id,
        'url': url,
      };

  @override
  String toString() {
    return 'MediaMetadata{id: $id, url: $url}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url;

  @override
  int get hashCode => id.hashCode ^ url.hashCode;
}
