import '../../entities/user.dart';

abstract class UserRepository {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  Future<void> addCurrentUserData(UserModel addUserReq);

  Future<void> updateCurrentUserData(UserModel updateUserReq);

  Future<List<String>> getUserRelatedData(String uid, String datatype);
}
