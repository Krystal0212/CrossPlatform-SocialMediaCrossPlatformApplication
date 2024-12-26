import '../../entities/user.dart';

abstract class UserRepository {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  Future<void> addCurrentUserData(UserModel addUserReq);

  Future<void> updateCurrentUserData(UserModel updateUserReq);

  Future<List<Map<String, String>>> fetchCategoriesData();

  Future<List<String>> getUserFollowers(String uid);

  Future<List<String>> getUserFollowings(String uid);

  Future<List<String>> getUserCollectionIDs(String uid);
}
