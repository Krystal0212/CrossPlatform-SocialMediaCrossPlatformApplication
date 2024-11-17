import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/profile_and_setting/cubit/profile_state.dart';

import '../../../../data/models/user_firestore/update_user_req.dart';
import '../../../../data/repository/auth/auth_repository_impl.dart';
import '../../../../data/repository/collection/collection_repository_impl.dart';
import '../../../../data/repository/post/post_repository_impl.dart';
import '../../../../data/repository/user/user_repository_impl.dart';
import '../../../../domain/entities/collection.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repository/auth/auth_repository.dart';
import '../../../../domain/repository/collection/collection_repository.dart';
import '../../../../domain/repository/post/post_repository.dart';
import '../../../../domain/repository/user/user_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  AuthRepository authRepository = AuthRepositoryImpl();
  UserRepository userRepository = UserRepositoryImpl();
  CollectionRepository collectionRepository = CollectionRepositoryImpl();
  PostRepository postRepository = PostRepositoryImpl();

  ProfileCubit() : super(ProfileLoading());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {

      final User? currentUser = await authRepository.getCurrentUser();
      final UserModel? userModel = await userRepository.getCurrentUserData();

      final userFollowers = await userRepository.getUserFollowers(currentUser!.uid);
      final userFollowings = await userRepository.getUserFollowings(currentUser.uid);
      final userCollectionIDs = await userRepository.getUserCollectionIDs(currentUser.uid);
      final List<CollectionModel> collections = await collectionRepository.getCollectionsData(userCollectionIDs);


      if (userModel != null) {
        emit(ProfileLoaded(
            userModel, userFollowers, userFollowings, collections));
      } else {
        emit(ProfileError("User data not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    emit(ProfileLoading());
    try {
      UpdateUserReq updateUserReq = UpdateUserReq(updatedUser);
      await userRepository.updateCurrentUserData(updateUserReq);
      fetchProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfileWithEmail(UserModel updatedUser) async {
    emit(ProfileLoading());
    try {
      UpdateUserReq updateUserReq = UpdateUserReq(updatedUser);
      updatedUser.resetState();
      await userRepository.updateCurrentUserData(updateUserReq);

      emit(ProfileEmailChanged());
    } catch (e) {
      if (e is FirebaseAuthException) {
        emit(ProfileError(e.toString()));
      } else {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      emit(ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError('Logout failed: $e'));
    }
  }
}
