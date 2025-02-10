import 'package:socialapp/utils/import.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final UserModel user;
  final Stream<List<NotificationModel>> notificationListStream;

  NotificationLoaded(this.user, this.notificationListStream);
}

class NotificationDeleteSuccess extends NotificationState {}

class NotificationDeleting extends NotificationState {}

class NotificationLoggedOut extends NotificationState{}

class NotificationError extends NotificationState {
}


