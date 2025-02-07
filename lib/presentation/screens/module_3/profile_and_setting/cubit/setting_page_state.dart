import 'dart:async';

import 'package:socialapp/domain/entities/user.dart';

abstract class SettingPartState {}

class SettingPartInitial extends SettingPartState {}

class SettingPartLoaded extends SettingPartState {
  final UserModel user;
  final bool isGoogleUserWithoutPassword;

  SettingPartLoaded( {required this.user, required this.isGoogleUserWithoutPassword});
}