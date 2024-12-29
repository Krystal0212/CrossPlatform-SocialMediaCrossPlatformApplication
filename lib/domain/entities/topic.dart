class TopicModel{
  final String topicId;
  final String name;
  final String thumbnailUrl;

  TopicModel( { required this.topicId,
    required this.name,
    required this.thumbnailUrl,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map, String topicId) {
    return TopicModel(
      name: map['name'],
      thumbnailUrl: map['url'], topicId: topicId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': thumbnailUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicModel && other.name == name && other.topicId == topicId && other.thumbnailUrl == thumbnailUrl;
  }

  @override
  int get hashCode => name.hashCode ^ topicId.hashCode ^ thumbnailUrl.hashCode;
}