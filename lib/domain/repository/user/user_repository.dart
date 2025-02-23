import 'package:socialapp/utils/import.dart';

abstract class UserRepository {
  Future<UserModel?>? getUserData(String userID);

  Future<UserModel?>? getCurrentUserData();

  Stream<UserModel?> streamCurrentUserData();

  Future<void> addCurrentUserData(UserModel addUserReq);

  Future<bool> updateCurrentUserData(UserModel updatedUserData,
      UserModel previousUserData, Uint8List? newAvatar);

  Future<Map<String, dynamic>> getUserRelatedData(String uid);

  Future<void> followOrUnfollowUser(String uid, bool? isFollow);

  Future<void> updateCurrentUserNSFWOption(bool isNSFWFilterTurnOn);
}
