import 'package:socialapp/utils/import.dart';

class UserRepositoryImpl extends UserRepository {
  @override
  Future<void> addCurrentUserData(UserModel addUserReq) {
    return serviceLocator<UserService>().addCurrentUserData(addUserReq);
  }

  @override
  Future<UserModel?>? getCurrentUserData() {
    return serviceLocator<UserService>().getCurrentUserData();
  }

  @override
  Future<UserModel?>? getUserData(String userID) {
    return serviceLocator<UserService>().getUserData(userID);
  }

  @override
  Future<bool> updateCurrentUserData(UserModel updatedUserData,
      UserModel previousUserData, Uint8List? newAvatar) {
    return serviceLocator<UserService>().updateCurrentUserData(updatedUserData, previousUserData, newAvatar);
  }

  @override
  Future<Map<String, dynamic>> getUserRelatedData(String uid) {
    return serviceLocator<UserService>().getUserRelatedData(uid);
  }

  @override
  Future<void> followOrUnfollowUser(String uid, bool? isFollow) {
    return serviceLocator<UserService>().followOrUnfollowUser(uid, isFollow);
  }

  @override
  Future<void> updateCurrentUserNSFWOption(bool isNSFWFilterTurnOn) {
    return serviceLocator<UserService>().updateCurrentUserNSFWOption(isNSFWFilterTurnOn);
  }
}
