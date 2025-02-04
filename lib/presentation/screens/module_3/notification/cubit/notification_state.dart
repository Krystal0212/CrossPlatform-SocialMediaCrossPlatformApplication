import 'package:socialapp/utils/import.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoggedOut extends NotificationState{}

class NotificationEmailChanged extends NotificationState{}

class NotificationError extends NotificationState {
}


