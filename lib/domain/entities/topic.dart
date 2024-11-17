class TopicModel {
  final String name;
  final String thumbnail;

  TopicModel({
    required this.name,
    required this.thumbnail,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      name: json['name'],
      thumbnail: json['thumbnail'],
    );
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      name: map['name'],
      thumbnail: map['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'thumbnail': thumbnail,
    };
  }
}