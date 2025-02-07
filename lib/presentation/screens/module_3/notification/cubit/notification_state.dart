import 'package:socialapp/utils/import.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final UserModel user;

  NotificationLoaded(this.user);
}

class NotificationLoggedOut extends NotificationState{}

class NotificationError extends NotificationState {
}


