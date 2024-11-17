import 'package:socialapp/data/models/user_firestore/add_user_data.dart';
import 'package:socialapp/data/models/user_firestore/update_user_req.dart';

import '../../entities/user.dart';

abstract class UserRepository {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  Future<void> addCurrentUserData(AddUserReq addUserReq);

  Future<void> updateCurrentUserData(UpdateUserReq updateUserReq);

  Future<List<Map<String, String>>> fetchCategoriesData();

  Future<List<String>> getUserFollowers(String uid);

  Future<List<String>> getUserFollowings(String uid);

  Future<List<String>> getUserCollectionIDs(String uid);
}
