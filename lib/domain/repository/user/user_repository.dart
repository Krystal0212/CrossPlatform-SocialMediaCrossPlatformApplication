import 'package:socialapp/utils/import.dart';

abstract class UserRepository {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  Future<void> addCurrentUserData(UserModel addUserReq);

  Future<void> updateCurrentUserData(UserModel updateUserReq);

  Future<Map<String, dynamic>> getUserRelatedData(String uid);

  Future<String>? uploadAvatar(File image, String uid);
}
