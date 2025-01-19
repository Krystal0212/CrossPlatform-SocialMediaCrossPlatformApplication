import 'package:socialapp/utils/import.dart';

abstract class UserRepository {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  Future<void> addCurrentUserData(UserModel addUserReq);

  Future<void> updateCurrentUserData(UserModel updateUserReq);

  Future<List<String>> getUserRelatedData(String uid, String datatype);

  Future<String>? uploadAvatar(File image, String uid);
}
