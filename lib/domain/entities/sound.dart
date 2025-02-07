class PreviewSoundPostModel {
  final String postId;
  final String recordUrl;

  PreviewSoundPostModel({
    required this.postId,
    required this.recordUrl,
  });

  factory PreviewSoundPostModel.fromMap(Map<String, dynamic> map) {
    return PreviewSoundPostModel(
      postId: map['postId'] as String,
      recordUrl: map['mediasOrThumbnailUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'mediasOrThumbnailUrl': recordUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreviewSoundPostModel &&
        other.postId == postId &&
        other.recordUrl == recordUrl;
  }

  @override
  int get hashCode => Object.hash(postId, recordUrl);
}