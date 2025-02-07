import 'package:socialapp/utils/import.dart';

import 'setting_page_state.dart';

class SettingPartCubit extends Cubit<SettingPartState> {
  UserModel currentUser = UserModel.empty();

  SettingPartCubit() : super(SettingPartInitial()) {
    loadData();
  }

  void loadData() async {
    currentUser =
    (await serviceLocator.get<UserService>().getCurrentUserData())!;
    bool isRawGoogleUser = _checkGoogleUserWithoutPassword();

    emit(SettingPartLoaded(
        isGoogleUserWithoutPassword: isRawGoogleUser, user: currentUser));
  }

  bool _checkGoogleUserWithoutPassword() {
    try {
      return serviceLocator
          .get<AuthRepository>()
          .isCurrentUserGoogleUserWithoutPassword();
    } catch (error) {
      if (kDebugMode) {
        print('Error during checking google user without password: $error');
      }
      return false;
    }
  }

  Future<void> updateNSFWFilter(bool isNSFWFilterTurnOn) async {
    try {
      await serviceLocator.get<UserRepository>().updateCurrentUserNSFWOption(
          isNSFWFilterTurnOn);
    }
    catch (error) {
      if (kDebugMode) {
        print('Error during updating NSFW filter: $error');
      }
    }
  }
}

class NSFWToggleScreenCubit extends Cubit<SettingPartState> {
  UserModel currentUser = UserModel.empty();

  NSFWToggleScreenCubit() : super(SettingPartInitial());

  Future<void> updateNSFWFilter(bool isNSFWFilterTurnOn) async {
    try {
      await serviceLocator.get<UserRepository>().updateCurrentUserNSFWOption(
          isNSFWFilterTurnOn);
    }
    catch (error) {
      if (kDebugMode) {
        print('Error during updating NSFW filter: $error');
      }
    }
  }}