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
  Future<void> updateCurrentUserData(UserModel updateUserReq) {
    return serviceLocator<UserService>().updateCurrentUserData(updateUserReq);
  }

  @override
  Future<Map<String, dynamic>> getUserRelatedData(String uid) {
    return serviceLocator<UserService>().getUserRelatedData(uid);
  }

  @override
  Future<String>? uploadAvatar(File image, String uid) {
    return serviceLocator<UserService>().uploadAvatar(image, uid);
  }
}
