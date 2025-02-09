import 'package:socialapp/utils/import.dart';

import '../../../../../data/sources/firestore/notification_service_impl.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService = NotificationServiceImpl();

  NotificationCubit() : super(NotificationInitial()) {
    _initialize();
  }

  void _initialize() async {
    await fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final UserModel? userModel =
          await serviceLocator<UserRepository>().getCurrentUserData();

      Stream<List<NotificationModel>> notificationSnapshot =
      _notificationService.getNotificationStreamOfCurrentUser();

      if (userModel != null) {
        emit(NotificationLoaded(userModel, notificationSnapshot));
      } else {
        throw "User data not found";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
      emit(NotificationError());
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
  }

  Future<void> markAllNotificationsAsRead() async {
  }

  Future<void> deleteNotification(String notificationId) async {
  }

  Future<void> deleteAllNotifications() async {
  }

  Future <UserModel> getUserDataFromUserRef(DocumentReference otherUserRef) async {
    return await _notificationService.getUserDataFromRef(otherUserRef);
  }
}
