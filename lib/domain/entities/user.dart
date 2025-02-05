class UserModel {
  String? id;
  final String tagName;
  final String name;
  final String email;
  final String lastName;
  final String location;

  final String avatar;
  bool emailChanged;
  bool avatarChanged;
  late final Map<String, String> preferredTopics;

  UserModel({
    this.id,
    required this.name,
    required this.lastName,
    required this.location,
    required this.preferredTopics,
    required this.avatar,
    required this.email,
    required this.tagName,
    this.emailChanged = false,
    this.avatarChanged = false,
  });

  UserModel.empty()
      : name = '',
        lastName = '',
        location = '',
        emailChanged = false,
        avatarChanged = false,
        tagName = '',
        avatar = '',
        email = '';

  UserModel.newUser(Map<String, bool> chosenTopics, String? userAvatar,
      String? userEmail, this.tagName)
      : name = '',
        lastName = '',
        location = '',
        emailChanged = false,
        avatarChanged = false,
        avatar = userAvatar!,
        email = userEmail!{
    preferredTopics = toPreferredTopic(chosenTopics);
  }

  Map<String, String> toPreferredTopic(Map<String, bool> chosenTopics) {
    int number = 0;
    Map<String, String> results = chosenTopics.map((key, _) {
      number += 1;
      return MapEntry(number.toString(), key.toString());
    });

    return results;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      emailChanged: false,
      avatarChanged: false,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      lastName: map['lastname'] ?? '',
      location: map['location'] ?? '',
      preferredTopics: Map<String, String>.from(
        map['preferred-topics'],
      ),
      avatar: map['avatar'] ?? '',
      tagName: map['tag-name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastname': lastName,
      'email': email,
      'location': location,
      'avatar': avatar,
      'tag-name': tagName,
    };
  }

  UserModel resetState() {
    return UserModel(
      emailChanged: false,
      avatarChanged: false,
      avatar: avatar,
      name: name,
      lastName: lastName,
      location: location,
      preferredTopics: preferredTopics,
      email: email,
      tagName: tagName,
    );
  }

  UserModel copyWith({
    String? name,
    String? newEmail,
    String? lastName,
    String? location,
    Map<String, String>? preferredTopics,
    String? newAvatar,
    Map<String, String>? socialAccounts,
    List<String>? followers,
    List<String>? followingUsers,
    String? tagName,
  }) {
    if (newEmail != null && newEmail != email) {
      emailChanged = true;
    }
    if (newAvatar != null && newAvatar != avatar) {
      avatarChanged = true;
    }
    return UserModel(
      emailChanged: emailChanged,
      avatar: newAvatar ?? avatar,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      location: location ?? this.location,
      preferredTopics: preferredTopics ?? this.preferredTopics,
      email: newEmail ?? email,
      tagName: tagName ?? this.tagName,
    );
  }
}
