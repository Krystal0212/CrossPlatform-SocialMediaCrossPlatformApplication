import 'package:socialapp/utils/import.dart';

import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial()) {
    // _initialize();
  }

  // void _initialize() async {
  //   await fetchProfile();
  // }

  Future<UserModel> fetchUserData() async {
    try {
      final User? currentUser =
          await serviceLocator<AuthRepository>().getCurrentUser();
      final UserModel? userModel =
          await serviceLocator<UserRepository>().getCurrentUserData();

      if (currentUser != null && userModel != null) {
        return userModel;
      } else {
        throw "User data not found";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
      return UserModel.empty();
    }
  }
}
