import 'package:socialapp/utils/import.dart';

import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
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

      if (userModel != null) {
        emit(NotificationLoaded(userModel));
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
}
