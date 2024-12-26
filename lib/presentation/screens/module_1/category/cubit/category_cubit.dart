import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/data/repository/auth/auth_repository_impl.dart';
import 'package:socialapp/domain/entities/user.dart';
import 'package:socialapp/presentation/screens/category/cubit/category_state.dart';
import 'package:socialapp/service_locator.dart';

import '../../../../domain/repository/auth/auth_repository.dart';
import '../../../../domain/repository/user/user_repository.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(GetCategoryIDInitial());

  AuthRepository authRepository = AuthRepositoryImpl();
  String? _category;

  void getCategoryId(String? categoryId) async {
    if (categoryId == null) {
      emit(GetCategoryIDFailure());
    } else {
      _category = categoryId;
      emit(GetCategoryIDSuccess());
    }
  }

  void addCurrentUserData(BuildContext context) async{
    User? currentUser = await authRepository.getCurrentUser();
    try {
      emit(AddUserLoading());
      UserModel userModel =
          UserModel.newUser(_category!, currentUser!.photoURL, currentUser.email);
      serviceLocator<UserRepository>().addCurrentUserData(userModel);
      emit(AddUserSuccess());
    } catch (e) {
      emit(AddUserFailure());
      if (kDebugMode) {
        print("Error add user: $e");
      }
    }
  }
}
