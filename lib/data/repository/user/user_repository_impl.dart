import 'package:socialapp/data/models/user_firestore/add_user_data.dart';

import 'package:socialapp/data/models/user_firestore/update_user_req.dart';

import 'package:socialapp/domain/entities/user.dart';

import '../../../domain/repository/user/user_repository.dart';
import '../../../service_locator.dart';
import '../../sources/firestore/firestore_service.dart';

class UserRepositoryImpl extends UserRepository {
  @override
  Future<void> addCurrentUserData(AddUserReq addUserReq) {
    return serviceLocator<FirestoreService>().addCurrentUserData(addUserReq);
  }

  @override
  Future<UserModel?>? getCurrentUserData() {
    return serviceLocator<FirestoreService>().getCurrentUserData();
  }

  @override
  Future<UserModel?>? getUserData(String userID) {
    return serviceLocator<FirestoreService>().getUserData(userID);
  }

  @override
  Future<void> updateCurrentUserData(UpdateUserReq updateUserReq) {
    return serviceLocator<FirestoreService>()
        .updateCurrentUserData(updateUserReq);
  }

  @override
  Future<List<Map<String, String>>> fetchCategoriesData() {
    return serviceLocator<FirestoreService>().fetchCategoriesData();
  }

  @override
  Future<List<String>> getUserFollowers(String uid) {
    return serviceLocator<FirestoreService>().getUserFollowers(uid);
  }

  @override
  Future<List<String>> getUserFollowings(String uid) {
    return serviceLocator<FirestoreService>().getUserFollowings(uid);
  }

  @override
  Future<List<String>> getUserCollectionIDs(String uid){
    return serviceLocator<FirestoreService>().getUserCollectionIDs(uid);
  }

}
