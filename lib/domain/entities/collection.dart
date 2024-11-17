class CollectionModel {
  final String collectionId;
  final String name;
  final String thumbnail;

  CollectionModel({
    required this.collectionId,
    required this.name,
    required this.thumbnail,
  });

  // factory CollectionModel.fromJson(Map<String, dynamic> json) {
  //   return CollectionModel(
  //     name: json['name'],
  //     thumbnail: json['thumbnail'],
  //   );
  // }

  // factory CollectionModel.fromMap(Map<String, dynamic> map) {
  //   return CollectionModel(
  //     name: map['name'],
  //     thumbnail: map['thumbnail'],
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'thumbnail': thumbnail,
  //   };
  // }

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      collectionId: map['collectionId'] ?? '',  // Provide default value if null
      name: map['name'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'name': name,
      'thumbnail': thumbnail,
    };
  }

}