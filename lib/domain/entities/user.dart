import 'package:socialapp/utils/import.dart';

class UserModel {
  final String name;
  final String email;
  final String lastName;
  final String location;

  final String avatar;
  bool emailChanged;
  bool avatarChanged;
  late final Map<String, String> preferredTopics;
  final Map<String, String> socialAccounts;

  UserModel({
    required this.name,
    required this.lastName,
    required this.location,
    required this.preferredTopics,
    required this.avatar,
    required this.email,
    required this.socialAccounts,
    this.emailChanged = false,
    this.avatarChanged = false,
  });

  UserModel.newUser(
      Map<String, bool> chosenTopics, String? userAvatar, String? userEmail)
      : name = '',
        lastName = '',
        location = '',
        emailChanged = false,
        avatarChanged = false,
        avatar = userAvatar!,
        email = userEmail!,
        socialAccounts = {} {
    preferredTopics = toPreferredTopic(chosenTopics);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      emailChanged: false,
      avatarChanged: false,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      lastName: map['lastname'] ?? '',
      location: map['location'] ?? '',
      preferredTopics: Map<String, String>.from(
        (map['preferred-topics'] ?? {}).map(
              (key, value) {
              return MapEntry(key, value.toString());  // Or any other field you need from the reference
            },
        ),
      ),
      avatar: map['avatar'] ?? '',
      socialAccounts: Map<String, String>.from(map['socials'] ?? {}),
    );
  }

  Map<String, String> toPreferredTopic(Map<String, bool> chosenTopics) {
    int number = 0;
    Map<String, String> results = chosenTopics.map((key, _) {
      number += 1;
      return MapEntry(number.toString(), key.toString());
    });

    return results;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastname': lastName,
      'email': email,
      'location': location,
      'preferred-topics': preferredTopics,
      'avatar': avatar,
      'socials': socialAccounts,
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
      socialAccounts: socialAccounts,
      email: email,
    );
  }

  @override
  String toString() {
    return 'UserModel{name: $name, email: $email, lastName: $lastName, location: $location, avatar: $avatar, emailChanged: $emailChanged, avatarChanged: $avatarChanged, preferredTopics: $preferredTopics, socialAccounts: $socialAccounts}';
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
      socialAccounts: socialAccounts ?? this.socialAccounts,
      email: newEmail ?? email,
    );
  }
}
