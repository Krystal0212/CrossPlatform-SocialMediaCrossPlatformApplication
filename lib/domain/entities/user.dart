// Name the class UserModel to avoid duplicating the name of User class
// in Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String email;
  final String lastName;
  final String location;
  final String category;
  final String avatar;
  bool emailChanged;
  bool avatarChanged;
  final Map<String, String> socialAccounts;

  UserModel({
    required this.name,
    required this.lastName,
    required this.location,
    required this.category,
    required this.avatar,
    required this.email,
    required this.socialAccounts,
    this.emailChanged = false,
    this.avatarChanged = false,
  });

  UserModel.newUser(String categoryID, String? userAvatar, String? userEmail)
      : name = '',
        lastName = '',
        location = '',
        emailChanged = false,
        avatarChanged = false,
        category = categoryID,
        avatar = userAvatar!,
        email = userEmail!,
        socialAccounts = {};

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      emailChanged: false,
      avatarChanged: false,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      lastName: map['lastname'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] is DocumentReference
          ? (map['category'] as DocumentReference).id
          : '',
      avatar: map['avatar'] ?? '',
      socialAccounts: Map<String, String>.from(map['socials'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastname': lastName,
      'email': email,
      'location': location,
      'category': category,
      'avatar': avatar,
      'socials': socialAccounts,
    };
  }

  UserModel resetState(){
    return UserModel(
      emailChanged: false,
      avatarChanged: false,
      avatar:  avatar,
      name:  name,
      lastName: lastName,
      location: location,
      category: category ,
      socialAccounts: socialAccounts,
      email: email,
    );
}

  UserModel copyWith({
    String? name,
    String? newEmail,
    String? lastName,
    String? location,
    String? category,
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
      category: category ?? this.category,
      socialAccounts: socialAccounts ?? this.socialAccounts,
      email: newEmail ?? email,
    );
  }
}
